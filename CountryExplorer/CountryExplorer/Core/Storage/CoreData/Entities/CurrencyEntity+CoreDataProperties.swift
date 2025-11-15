//
//  CurrencyEntity+CoreDataProperties.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import CoreData

extension CurrencyEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyEntity> {
        return NSFetchRequest<CurrencyEntity>(entityName: "CurrencyEntity")
    }
    
    @NSManaged public var code: String
    @NSManaged public var name: String
    @NSManaged public var symbol: String
    @NSManaged public var country: CountryEntity?
}

extension CurrencyEntity: Identifiable {
    
}

