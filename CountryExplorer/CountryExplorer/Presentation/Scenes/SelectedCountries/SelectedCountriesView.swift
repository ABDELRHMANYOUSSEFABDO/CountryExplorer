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
                List {
                    ForEach(rows) { row in
                        Button {
                            HapticManager.shared.light()
                            viewModel.didSelectCountry(id: row.id)
                        } label: {
                            CountryRowView(row: row)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowInsets(EdgeInsets(
                            top: AppTheme.Spacing.sm,
                            leading: AppTheme.Spacing.md,
                            bottom: AppTheme.Spacing.sm,
                            trailing: AppTheme.Spacing.md
                        ))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                HapticManager.shared.medium()
                                withAnimation(AppTheme.Animation.spring) {
                                    viewModel.didRemoveCountry(id: row.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
        }
    }
}
