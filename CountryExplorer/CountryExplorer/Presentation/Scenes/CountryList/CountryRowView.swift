//
//  CountryRowView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct CountryRowView: View {
    let row: CountryRowViewModel

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Flag/Icon Circle
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.gradient1)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "flag.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .shadow(
                color: AppTheme.Colors.primary.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            
            // Content
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(row.name)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                HStack(spacing: 4) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Text(row.capital)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    Circle()
                        .fill(AppTheme.Colors.textSecondary.opacity(0.5))
                        .frame(width: 3, height: 3)
                    
                    Text(row.region)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                HStack(spacing: AppTheme.Spacing.sm) {
                    // Population Badge
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 9))
                        Text(row.populationText)
                            .font(AppTheme.Typography.caption)
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.sm)
                    
                    // Currency Badge
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 9))
                        Text(row.currencyText)
                            .font(AppTheme.Typography.caption)
                    }
                    .foregroundColor(AppTheme.Colors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.accent.opacity(0.1))
                    .cornerRadius(AppTheme.CornerRadius.sm)
                }
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.5))
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
