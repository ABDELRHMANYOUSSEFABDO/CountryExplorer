//
//  LocationService.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Location Errors
enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case geocodingFailed
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .locationUnavailable:
            return "Unable to determine location"
        case .geocodingFailed:
            return "Failed to determine country from location"
        case .timeout:
            return "Location request timed out"
        }
    }
}

// MARK: - Location Result
struct LocationResult {
    let countryCode: String
    let countryName: String
    let latitude: Double
    let longitude: Double
}

// MARK: - Location Service Protocol
protocol LocationServiceProtocol {
    func requestLocationPermission()
    func getCurrentCountryCode() -> AnyPublisher<LocationResult, LocationError>
    var authorizationStatus: CLAuthorizationStatus { get }
}

// MARK: - Location Service Implementation
final class LocationService: NSObject, LocationServiceProtocol {
    
    private let locationManager: CLLocationManager
    private var locationSubject: PassthroughSubject<LocationResult, LocationError>?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000 // 1km
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentCountryCode() -> AnyPublisher<LocationResult, LocationError> {
        let subject = PassthroughSubject<LocationResult, LocationError>()
        self.locationSubject = subject
        
        // Check authorization status
        let status = authorizationStatus
        
        switch status {
        case .notDetermined:
            // Request permission first
            locationManager.requestWhenInUseAuthorization()
            // Will continue in delegate method
            
        case .restricted, .denied:
            subject.send(completion: .failure(.permissionDenied))
            return subject.eraseToAnyPublisher()
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Start location updates
            locationManager.startUpdatingLocation()
            
        @unknown default:
            subject.send(completion: .failure(.locationUnavailable))
            return subject.eraseToAnyPublisher()
        }
        
        // Timeout after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self else { return }
            self.locationManager.stopUpdatingLocation()
            if self.locationSubject != nil {
                subject.send(completion: .failure(.timeout))
                self.locationSubject = nil
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    private func geocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            self.locationManager.stopUpdatingLocation()
            
            if let error = error {
                Logger.shared.error("Geocoding error: \(error.localizedDescription)")
                self.locationSubject?.send(completion: .failure(.geocodingFailed))
                self.locationSubject = nil
                return
            }
            
            guard let placemark = placemarks?.first,
                  let countryCode = placemark.isoCountryCode,
                  let countryName = placemark.country else {
                self.locationSubject?.send(completion: .failure(.geocodingFailed))
                self.locationSubject = nil
                return
            }
            
            let result = LocationResult(
                countryCode: countryCode,
                countryName: countryName,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            Logger.shared.info("Location detected: \(countryName) (\(countryCode))")
            
            self.locationSubject?.send(result)
            self.locationSubject?.send(completion: .finished)
            self.locationSubject = nil
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = authorizationStatus
        
        Logger.shared.info("Location authorization changed: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            // Start location updates if we have a pending request
            if locationSubject != nil {
                locationManager.startUpdatingLocation()
            }
            
        case .denied, .restricted:
            locationSubject?.send(completion: .failure(.permissionDenied))
            locationSubject = nil
            
        case .notDetermined:
            break
            
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Logger.shared.info("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        // Geocode to get country
        geocodeLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.shared.error("Location error: \(error.localizedDescription)")
        
        locationManager.stopUpdatingLocation()
        locationSubject?.send(completion: .failure(.locationUnavailable))
        locationSubject = nil
    }
}

