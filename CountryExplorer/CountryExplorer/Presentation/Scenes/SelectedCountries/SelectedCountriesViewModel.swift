//
//  SelectedCountriesViewModel.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import Foundation
import Combine

protocol SelectedCountriesViewModelProtocol: ObservableObject {
    var state: ViewState<[CountryRowViewModel]> { get }

    func onAppear()
    func didRemoveCountry(id: String)
}

final class SelectedCountriesViewModel: SelectedCountriesViewModelProtocol {

    @Published private(set) var state: ViewState<[CountryRowViewModel]> = .idle

    private let manageSelectedUseCase: ManageSelectedCountriesUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    init(manageSelectedUseCase: ManageSelectedCountriesUseCaseProtocol) {
        self.manageSelectedUseCase = manageSelectedUseCase
    }

    func onAppear() {
        loadSelectedCountries()
    }

//    func didRemoveCountry(id: String) {
//        guard case let .content(rows) = state,
//              let row = rows.first(where: { $0.id == id }) else { return }
//
//        manageSelectedUseCase.remove(countryId: id)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completion in
//                if case .failure(let error) = completion {
//                    self?.state = .error(error.localizedDescription)
//                }
//            } receiveValue: { [weak self] in
//                self?.loadSelectedCountries()
//            }
//            .store(in: &cancellables)
//    }

    func didRemoveCountry(id: String) {
        guard case let .content(rows) = state,
              let row = rows.first(where: { $0.id == id }) else { return }

        manageSelectedUseCase.remove(row.country)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.state = .error("Failed to remove country")
                }
            } receiveValue: { [weak self] in
                self?.loadSelectedCountries()
            }
            .store(in: &cancellables)
    }

    private func loadSelectedCountries() {
        state = .loading

        manageSelectedUseCase.getSelected()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] countries in
                guard let self else { return }
                let rows = countries.map(CountryRowViewModel.init)
                self.state = .content(rows)
            }
            .store(in: &cancellables)
    }
}
