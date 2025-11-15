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
            
            // Success/Error Toast Message
            if let message = viewModel.addCountryMessage {
                VStack {
                    Spacer()
                    Text(message)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            message.contains("✅") ? Color.green : Color.red
                        )
                        .cornerRadius(AppTheme.CornerRadius.lg)
                        .shadow(
                            color: AppTheme.Shadows.medium.color,
                            radius: AppTheme.Shadows.medium.radius,
                            x: AppTheme.Shadows.medium.x,
                            y: AppTheme.Shadows.medium.y
                        )
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(), value: viewModel.addCountryMessage)
            }
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
                List {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
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
                            Button {
                                HapticManager.shared.medium()
                                viewModel.didAddCountry(id: row.id)
                            } label: {
                                Label("Add", systemImage: "plus.circle.fill")
                            }
                            .tint(AppTheme.Colors.primary)
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

