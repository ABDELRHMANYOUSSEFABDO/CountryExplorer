//
//  CountryDetailsViewModel.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

protocol CountryDetailsViewModelProtocol: ObservableObject {
    var country: Country { get }
}

final class CountryDetailsViewModel: CountryDetailsViewModelProtocol {
    @Published private(set) var country: Country

    init(country: Country) {
        self.country = country
    }
}
