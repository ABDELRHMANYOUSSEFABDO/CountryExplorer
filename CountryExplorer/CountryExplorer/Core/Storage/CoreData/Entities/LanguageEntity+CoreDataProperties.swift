//
//  LanguageEntity+CoreDataProperties.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import CoreData

extension LanguageEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LanguageEntity> {
        return NSFetchRequest<LanguageEntity>(entityName: "LanguageEntity")
    }
    
    @NSManaged public var iso639_1: String?
    @NSManaged public var name: String
    @NSManaged public var nativeName: String?
    @NSManaged public var country: CountryEntity?
}

extension LanguageEntity: Identifiable {
    
}

