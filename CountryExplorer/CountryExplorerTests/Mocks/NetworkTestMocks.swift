//
//  NetworkTestMocks.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine
@testable import CountryExplorer


struct NetworkTestHelpers {

    static func makeMockCountryDTO() -> CountryDTO {
        CountryDTO(
            name: "Test Country",
            capital: "Test Capital",
            alpha2Code: "TC",
            alpha3Code: "TST",
            flag: nil,
            region: "Test Region",
            subregion: "Test Subregion",
            population: 1_000_000,
            currencies: [CurrencyDTO(code: "TCC", name: "Test Currency", symbol: "$")],
            languages: [LanguageDTO(iso639_1: "tc",
                                    iso639_2: "tst",
                                    name: "Test Language",
                                    nativeName: "Native")],
            timezones: ["UTC+00:00"],
            borders: ["TB1", "TB2"],
            nativeName: "Native Test Country",
            numericCode: "999",
            latlng: [0.0, 0.0]
        )
    }

    static func makeMockCountryJSON() -> String {
        """
        {
            "name": "Test Country",
            "capital": "Test Capital",
            "alpha2Code": "TC",
            "alpha3Code": "TST",
            "region": "Test Region",
            "subregion": "Test Subregion",
            "population": 1000000,
            "currencies": [{
                "code": "TCC",
                "name": "Test Currency",
                "symbol": "$"
            }],
            "languages": [{
                "iso639_1": "tc",
                "iso639_2": "tst",
                "name": "Test Language",
                "nativeName": "Native"
            }],
            "timezones": ["UTC+00:00"],
            "borders": ["TB1", "TB2"],
            "nativeName": "Native Test Country",
            "numericCode": "999",
            "latlng": [0.0, 0.0]
        }
        """
    }

    static func makeMockCountriesJSON() -> String {
        """
        [
            \(makeMockCountryJSON()),
            {
                "name": "Second Country",
                "capital": "Second Capital",
                "alpha2Code": "SC",
                "alpha3Code": "SND",
                "region": "Another Region",
                "population": 2000000,
                "currencies": [{
                    "code": "SCC",
                    "name": "Second Currency",
                    "symbol": "€"
                }]
            }
        ]
        """
    }
}
