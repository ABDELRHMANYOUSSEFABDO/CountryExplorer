//
//  ErrorView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    @State private var isAnimating = false

    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Error Icon
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.error.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.error, AppTheme.Colors.error.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .animation(
                Animation.spring(response: 0.6, dampingFraction: 0.7)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Oops! Something went wrong")
                    .font(AppTheme.Typography.title3)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.lg)
            }

            if let retryAction {
                Button(action: retryAction) {
                    HStack(spacing: AppTheme.Spacing.sm) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Try Again")
                            .font(AppTheme.Typography.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppTheme.Colors.gradient1)
                    .cornerRadius(AppTheme.CornerRadius.md)
                    .shadow(
                        color: AppTheme.Colors.primary.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .pressableStyle()
            }
        }
        .padding(AppTheme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}
