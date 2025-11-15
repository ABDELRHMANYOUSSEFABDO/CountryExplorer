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
        TabView {
            // Countries Tab - للبحث عن الدول
            buildCountriesTab(
                fetchAllUseCase: fetchAllUseCase,
                searchUseCase: searchUseCase,
                manageSelectedUseCase: manageSelectedUseCase
            )
            .tabItem {
                Label("Countries", systemImage: "globe.americas.fill")
            }
            
            // Selected Tab - للدول المختارة (الـ Main View)
            buildSelectedTab(manageSelectedUseCase: manageSelectedUseCase)
                .tabItem {
                    Label("Selected", systemImage: "star.fill")
                }
        }
    }
    
    @ViewBuilder
    private func buildCountriesTab(
        fetchAllUseCase: FetchAllCountriesUseCaseProtocol,
        searchUseCase: SearchCountriesUseCaseProtocol,
        manageSelectedUseCase: ManageSelectedCountriesUseCaseProtocol
    ) -> some View {
        let listVM = CountryListViewModel(
            fetchAllUseCase: fetchAllUseCase,
            searchUseCase: searchUseCase,
            manageSelectedUseCase: manageSelectedUseCase,
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
    
    @ViewBuilder
    private func buildSelectedTab(
        manageSelectedUseCase: ManageSelectedCountriesUseCaseProtocol
    ) -> some View {
        let selectedVM = SelectedCountriesViewModel(
            manageSelectedUseCase: manageSelectedUseCase,
            coordinator: self
        )
        
        NavigationStack(path: Binding(
            get: { self.path },
            set: { self.path = $0 }
        )) {
            SelectedCountriesView(viewModel: selectedVM)
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
