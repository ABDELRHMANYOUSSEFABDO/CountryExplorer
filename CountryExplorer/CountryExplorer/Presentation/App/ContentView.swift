//
//  ContentView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI
import Combine

struct ContentView: View {

    @StateObject private var coordinator = CountryFlowCoordinator()
    @State private var isShowingSplash = true
    @State private var cancellables = Set<AnyCancellable>()
    
    private let container: DIContainerProtocol = DIContainer.shared
    
    private lazy var firstLaunchManager: FirstLaunchManagerProtocol = {
        container.makeFirstLaunchManager()
    }()

    var body: some View {
        ZStack {
            // Main Content
            coordinator.buildRootView(
                fetchAllUseCase: UseCaseFactory.makeFetchAllCountriesUseCase(),
                searchUseCase: UseCaseFactory.makeSearchCountriesUseCase(),
                manageSelectedUseCase: UseCaseFactory.makeManageSelectedCountriesUseCase()
            )
            .opacity(isShowingSplash ? 0 : 1)
            
            // Splash Screen
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            handleFirstLaunch()
            
            // Show splash for 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isShowingSplash = false
                }
            }
        }
    }
    
    private func handleFirstLaunch() {
        firstLaunchManager.handleFirstLaunchIfNeeded()
            .sink { _ in
                Logger.shared.info("First launch handling completed")
            }
            .store(in: &cancellables)
    }
}
