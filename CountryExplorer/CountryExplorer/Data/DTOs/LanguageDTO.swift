//
//  LanguageDTO.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation

struct LanguageDTO: Decodable {
    let iso639_1: String?
    let iso639_2: String?
    let name: String?
    let nativeName: String?
}
