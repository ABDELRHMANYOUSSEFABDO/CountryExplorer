//
//  CountryDetailsView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct CountryDetailsView<ViewModel: CountryDetailsViewModelProtocol>: View {

    @StateObject private var viewModel: ViewModel
    @State private var isAnimating = false

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        let country = viewModel.country

        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Header Card
                    VStack(spacing: AppTheme.Spacing.md) {
                        // Flag/Icon
                        ZStack {
                            Circle()
                                .fill(AppTheme.Colors.gradient1)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "flag.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(
                            color: AppTheme.Colors.primary.opacity(0.3),
                            radius: 15,
                            x: 0,
                            y: 8
                        )
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(AppTheme.Animation.spring.delay(0.1), value: isAnimating)
                        
                        Text(country.name)
                            .font(AppTheme.Typography.largeTitle)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 20)
                            .animation(AppTheme.Animation.spring.delay(0.2), value: isAnimating)
                        
                        if let nativeName = country.nativeName {
                            Text(nativeName)
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(AppTheme.Animation.spring.delay(0.3), value: isAnimating)
                        }
                    }
                    .padding(AppTheme.Spacing.xl)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(AppTheme.CornerRadius.xl)
                    .shadow(
                        color: AppTheme.Shadows.medium.color,
                        radius: AppTheme.Shadows.medium.radius,
                        x: AppTheme.Shadows.medium.x,
                        y: AppTheme.Shadows.medium.y
                    )
                    
                    // Details Grid
                    VStack(spacing: AppTheme.Spacing.md) {
                        if !country.capital.isEmpty {
                            DetailCard(
                                icon: "building.2.fill",
                                label: "Capital",
                                value: country.capital,
                                color: AppTheme.Colors.primary
                            )
                            .opacity(isAnimating ? 1 : 0)
                            .offset(x: isAnimating ? 0 : -50)
                            .animation(AppTheme.Animation.spring.delay(0.4), value: isAnimating)
                        }
                        
                        DetailCard(
                            icon: "map.fill",
                            label: "Region",
                            value: country.region,
                            color: AppTheme.Colors.secondary
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : 50)
                        .animation(AppTheme.Animation.spring.delay(0.5), value: isAnimating)
                        
                        DetailCard(
                            icon: "person.2.fill",
                            label: "Population",
                            value: formatPopulation(country.population),
                            color: AppTheme.Colors.success
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(x: isAnimating ? 0 : -50)
                        .animation(AppTheme.Animation.spring.delay(0.6), value: isAnimating)
                        
                        if let currency = country.mainCurrency {
                            DetailCard(
                                icon: "dollarsign.circle.fill",
                                label: "Currency",
                                value: currency.displayName,
                                color: AppTheme.Colors.accent
                            )
                            .opacity(isAnimating ? 1 : 0)
                            .offset(x: isAnimating ? 0 : 50)
                            .animation(AppTheme.Animation.spring.delay(0.7), value: isAnimating)
                        }
                        
                        if !country.alpha2Code.isEmpty {
                            DetailCard(
                                icon: "tag.fill",
                                label: "Country Code",
                                value: "\(country.alpha2Code) / \(country.alpha3Code)",
                                color: AppTheme.Colors.error
                            )
                            .opacity(isAnimating ? 1 : 0)
                            .offset(x: isAnimating ? 0 : -50)
                            .animation(AppTheme.Animation.spring.delay(0.8), value: isAnimating)
                        }
                        
                        if !country.languages.isEmpty {
                            DetailCard(
                                icon: "text.bubble.fill",
                                label: "Languages",
                                value: country.languagesDescription,
                                color: AppTheme.Colors.primary
                            )
                            .opacity(isAnimating ? 1 : 0)
                            .offset(x: isAnimating ? 0 : 50)
                            .animation(AppTheme.Animation.spring.delay(0.9), value: isAnimating)
                        }
                    }
                }
                .padding(AppTheme.Spacing.md)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isAnimating = true
        }
    }
    
    private func formatPopulation(_ population: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: population)) ?? "\(population)"
    }
}

// MARK: - Detail Card
struct DetailCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Text(value)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            
            Spacer()
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.lg)
        .shadow(
            color: AppTheme.Shadows.small.color,
            radius: AppTheme.Shadows.small.radius,
            x: AppTheme.Shadows.small.x,
            y: AppTheme.Shadows.small.y
        )
    }
}

