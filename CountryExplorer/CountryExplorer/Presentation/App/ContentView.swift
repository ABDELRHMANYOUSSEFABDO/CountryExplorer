//
//  ContentView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var coordinator = CountryFlowCoordinator()
    @State private var isShowingSplash = true

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
            // Show splash for 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isShowingSplash = false
                }
            }
        }
    }
}
