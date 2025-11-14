//
//  CountryListViewModel.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

struct CountryRowViewModel: Identifiable, Equatable {
    let id: String
    let name: String
    let country: Country
    let capital: String
    let region: String
    let populationText: String
    let currencyText: String
    let flagURL: String

    init(country: Country) {
        self.country = country
        self.id = country.alpha3Code
        self.name = country.name
        self.capital = country.capital
        self.region = country.region
        self.populationText = Self.formatPopulation(country.population)
        self.currencyText = country.currencyDescription
        self.flagURL = country.flagPNGURL // Use PNG URL generated from alpha2Code
    }

    private static func formatPopulation(_ value: Int) -> String {
        guard value > 0 else { return "N/A" }
        if value >= 1_000_000 {
            return String(format: "%.1fM", Double(value) / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.1fk", Double(value) / 1_000)
        }
        return "\(value)"
    }
}

protocol CountryListViewModelProtocol: AnyObject, ObservableObject {
    var state: ViewState<[CountryRowViewModel]> { get }
    var searchQuery: String { get set }

    func onAppear()
    func refresh() async
    func didSelectCountry(id: String)
}

final class CountryListViewModel: CountryListViewModelProtocol {


    @Published private(set) var state: ViewState<[CountryRowViewModel]> = .idle
    @Published var searchQuery: String = ""


    private let fetchAllUseCase: FetchAllCountriesUseCaseProtocol
    private let searchUseCase: SearchCountriesUseCaseProtocol
    private let coordinator: CountryFlowCoordinating
    private var cancellables = Set<AnyCancellable>()

    private var allCountries: [Country] = []
    private var currentSearchResults: [Country] = []


    init(
        fetchAllUseCase: FetchAllCountriesUseCaseProtocol,
        searchUseCase: SearchCountriesUseCaseProtocol,
        coordinator: CountryFlowCoordinating
    ) {
        self.fetchAllUseCase = fetchAllUseCase
        self.searchUseCase = searchUseCase
        self.coordinator = coordinator

        bindSearch()
    }


    func onAppear() {
        guard case .idle = state else { return }
        loadAllCountries()
    }
    
    func refresh() async {
        await withCheckedContinuation { continuation in
            loadAllCountries(isRefresh: true)
            // Give a small delay for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                continuation.resume()
            }
        }
    }

    func didSelectCountry(id: String) {
        let countries = searchQuery.isEmpty ? allCountries : currentSearchResults
        guard let country = countries.first(where: { $0.alpha3Code == id }) else { return }
        coordinator.showCountryDetails(country)
    }


    private func loadAllCountries(isRefresh: Bool = false) {
        state = .loading

        fetchAllUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] countries in
                guard let self else { return }
                self.allCountries = countries
                
                // If refreshing and there's an active search, clear it
                if isRefresh {
                    self.searchQuery = ""
                    self.currentSearchResults = []
                }
                
                let rows = countries.map(CountryRowViewModel.init)
                self.state = .content(rows)
            }
            .store(in: &cancellables)
    }

    private func bindSearch() {
        $searchQuery
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            // Search cleared, show all countries
            currentSearchResults = []
            if !allCountries.isEmpty {
                state = .content(allCountries.map(CountryRowViewModel.init))
            } else if case .idle = state {
                // If search is cleared and we have no data, load all countries
                loadAllCountries()
            }
            return
        }

        state = .loading

        searchUseCase.execute(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] countries in
                guard let self else { return }
                // Store search results separately, don't override allCountries
                self.currentSearchResults = countries
                let rows = countries.map(CountryRowViewModel.init)
                self.state = rows.isEmpty
                    ? .content([])
                    : .content(rows)
            }
            .store(in: &cancellables)
    }
}
