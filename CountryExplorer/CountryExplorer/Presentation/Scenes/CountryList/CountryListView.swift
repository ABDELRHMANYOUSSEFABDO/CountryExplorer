//
//  CountryListView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct CountryListView<ViewModel: CountryListViewModelProtocol>: View {

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
        .navigationTitle("🌍 Countries")
        .searchable(
            text: $viewModel.searchQuery,
            prompt: "Search for a country..."
        )
        .refreshable {
            await refreshContent()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private func refreshContent() async {
        HapticManager.shared.light()
        await viewModel.refresh()
        HapticManager.shared.success()
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
                    title: "No countries found",
                    subtitle: "Try a different search keyword."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                            Button {
                                HapticManager.shared.light()
                                viewModel.didSelectCountry(id: row.id)
                            } label: {
                                CountryRowView(row: row)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .pressableStyle()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                            .animation(
                                AppTheme.Animation.spring.delay(Double(index) * 0.05),
                                value: rows.count
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                }
            }
        }
    }
}

