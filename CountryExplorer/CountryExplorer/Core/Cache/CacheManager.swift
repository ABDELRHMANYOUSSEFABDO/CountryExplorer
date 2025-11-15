//
//  CacheManager.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import UIKit

protocol CacheManagerProtocol {
    func set<T: Codable>(_ object: T, forKey key: String, expiration: CacheExpiration)
    func get<T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func remove(forKey key: String)
    func removeAll()
    func removeExpired()
}

enum CacheExpiration {
    case never
    case seconds(TimeInterval)
    case minutes(Int)
    case hours(Int)
    case days(Int)
    case date(Date)
    
    var expireDate: Date? {
        switch self {
        case .never:
            return nil
        case .seconds(let seconds):
            return Date().addingTimeInterval(seconds)
        case .minutes(let minutes):
            return Date().addingTimeInterval(TimeInterval(minutes * 60))
        case .hours(let hours):
            return Date().addingTimeInterval(TimeInterval(hours * 3600))
        case .days(let days):
            return Date().addingTimeInterval(TimeInterval(days * 86400))
        case .date(let date):
            return date
        }
    }
}

// MARK: - Cache Entry
struct CacheEntry<T: Codable>: Codable {
    let object: T
    let expireDate: Date?
    let createdDate: Date
    
    var isExpired: Bool {
        guard let expireDate = expireDate else { return false }
        return Date() > expireDate
    }
}

// MARK: - Cache Manager Implementation
final class CacheManager: CacheManagerProtocol {
    
    static let shared = CacheManager()
    
    private let memoryCache = NSCache<NSString, AnyObject>()
    private let diskCacheURL: URL
    private let ioQueue = DispatchQueue(label: "com.countryexplorer.cache", attributes: .concurrent)
    private let fileManager = FileManager.default
    
    init(memoryCapacity: Int = 50 * 1024 * 1024,
         diskCapacity: Int = 200 * 1024 * 1024) {
        
        // Configure memory cache
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = memoryCapacity
        
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("CountryExplorerCache")
        
        createCacheDirectoryIfNeeded()
        setupNotificationObservers()
        
        removeExpired()
    }
    
    // MARK: - Public Methods
    
    func set<T: Codable>(_ object: T, forKey key: String, expiration: CacheExpiration = .hours(1)) {
        let entry = CacheEntry(object: object, expireDate: expiration.expireDate, createdDate: Date())
        
        // Save to memory cache
        if let data = try? JSONEncoder().encode(entry) {
            let cost = data.count
            memoryCache.setObject(data as NSData, forKey: key as NSString, cost: cost)
        }
        
        // Save to disk cache asynchronously
        ioQueue.async(flags: .barrier) { [weak self] in
            self?.saveToDisk(entry, forKey: key)
        }
        
        Logger.shared.verbose("Cached object for key: \(key)")
    }
    
    func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        // Check memory cache first
        if let data = memoryCache.object(forKey: key as NSString) as? Data,
           let entry = try? JSONDecoder().decode(CacheEntry<T>.self, from: data) {
            if !entry.isExpired {
                Logger.shared.verbose("Cache hit (memory) for key: \(key)")
                return entry.object
            } else {
                // Remove expired entry
                remove(forKey: key)
            }
        }
        
        // Check disk cache
        var diskObject: T?
        ioQueue.sync {
            diskObject = loadFromDisk(type, forKey: key)
        }
        
        if let object = diskObject {
            // Update memory cache
            set(object, forKey: key, expiration: .never)
            Logger.shared.verbose("Cache hit (disk) for key: \(key)")
            return object
        }
        
        Logger.shared.verbose("Cache miss for key: \(key)")
        return nil
    }
    
    func remove(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        
        ioQueue.async(flags: .barrier) { [weak self] in
            self?.removeFromDisk(forKey: key)
        }
    }
    
    func removeAll() {
        memoryCache.removeAllObjects()
        
        ioQueue.async(flags: .barrier) { [weak self] in
            self?.removeAllFromDisk()
        }
    }
    
    func removeExpired() {
        ioQueue.async(flags: .barrier) { [weak self] in
            self?.removeExpiredFromDisk()
        }
    }
    
    // MARK: - Private Methods
    
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: diskCacheURL.path) {
            try? fileManager.createDirectory(at: diskCacheURL,
                                            withIntermediateDirectories: true)
        }
    }
    
    private func saveToDisk<T: Codable>(_ entry: CacheEntry<T>, forKey key: String) {
        let fileURL = diskCacheURL.appendingPathComponent(key.md5)
        
        do {
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL)
        } catch {
            Logger.shared.error("Failed to save cache to disk: \(error)")
        }
    }
    
    private func loadFromDisk<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        let fileURL = diskCacheURL.appendingPathComponent(key.md5)
        
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
            
            if !entry.isExpired {
                return entry.object
            } else {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            Logger.shared.error("Failed to load cache from disk: \(error)")
        }
        
        return nil
    }
    
    private func removeFromDisk(forKey key: String) {
        let fileURL = diskCacheURL.appendingPathComponent(key.md5)
        try? fileManager.removeItem(at: fileURL)
    }
    
    private func removeAllFromDisk() {
        try? fileManager.removeItem(at: diskCacheURL)
        createCacheDirectoryIfNeeded()
    }
    
    private func removeExpiredFromDisk() {
        guard let files = try? fileManager.contentsOfDirectory(at: diskCacheURL,
                                                              includingPropertiesForKeys: [.contentModificationDateKey]) else { return }
        
        for fileURL in files {
            if let data = try? Data(contentsOf: fileURL),
               let entry = try? JSONDecoder().decode(CacheEntry<Data>.self, from: data),
               entry.isExpired {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc private func didReceiveMemoryWarning() {
        memoryCache.removeAllObjects()
        Logger.shared.warning("Memory warning: Cleared memory cache")
    }
    
    @objc private func willTerminate() {
        removeExpired()
    }
}

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let ioQueue = DispatchQueue(label: "com.countryexplorer.imagecache")
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }
    
    func set(_ image: UIImage, forKey key: String) {
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let key = url.absoluteString
        
        // Check cache first
        if let cachedImage = get(forKey: key) {
            completion(cachedImage)
            return
        }
        
        // Download image
        ioQueue.async {
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache image
            self.set(image, forKey: key)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

// MARK: - String Extension for MD5
extension String {
    var md5: String {
        let utf8 = self.data(using: .utf8)!
        return utf8.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
    }
}
