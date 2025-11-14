//
//  SelectedCountriesView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct SelectedCountriesView<ViewModel: SelectedCountriesViewModelProtocol>: View {

    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            content
        }
        .navigationTitle("⭐️ Selected")
        .onAppear {
            viewModel.onAppear()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()

        case .error(let message):
            ErrorView(message: message) {
                viewModel.onAppear()
            }

        case .content(let rows):
            if rows.isEmpty {
                EmptyStateView(
                    title: "No selected countries",
                    subtitle: "Start exploring and add your favorite countries!"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        ForEach(rows) { row in
                            HStack(spacing: 0) {
                                CountryRowView(row: row)
                                
                                Button {
                                    HapticManager.shared.medium()
                                    withAnimation(AppTheme.Animation.spring) {
                                        viewModel.didRemoveCountry(id: row.id)
                                    }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                                            .fill(AppTheme.Colors.error.opacity(0.1))
                                            .frame(width: 60)
                                        
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(AppTheme.Colors.error)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                }
            }
        }
    }
}
