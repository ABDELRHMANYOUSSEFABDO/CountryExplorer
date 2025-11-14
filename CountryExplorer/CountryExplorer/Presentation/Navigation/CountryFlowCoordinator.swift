//
//  CountryFlowCoordinator.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

protocol CountryFlowCoordinating: AnyObject {
    func showCountryDetails(_ country: Country)
}

final class CountryFlowCoordinator: ObservableObject, CountryFlowCoordinating {

    enum Route: Hashable {
        case countryDetails(Country)
    }

    @Published var path = NavigationPath()

    func showCountryDetails(_ country: Country) {
        path.append(Route.countryDetails(country))
    }

    @ViewBuilder
    func buildRootView(
        fetchAllUseCase: FetchAllCountriesUseCaseProtocol,
        searchUseCase: SearchCountriesUseCaseProtocol,
        manageSelectedUseCase: ManageSelectedCountriesUseCaseProtocol
    ) -> some View {
        let listVM = CountryListViewModel(
            fetchAllUseCase: fetchAllUseCase,
            searchUseCase: searchUseCase,
            coordinator: self
        )

        NavigationStack(path: Binding(
            get: { self.path },
            set: { self.path = $0 }
        )) {
            CountryListView(viewModel: listVM)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .countryDetails(let country):
                        let vm = CountryDetailsViewModel(country: country)
                        CountryDetailsView(viewModel: vm)
                    }
                }
        }
    }
}
