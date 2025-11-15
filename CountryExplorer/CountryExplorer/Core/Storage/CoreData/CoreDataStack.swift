//
//  CoreDataStack.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//



import Foundation
import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "CountryExplorer")
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
        
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("❌ CoreData save error: \(error.localizedDescription)")
        }
    }
}
