//
//  LoadingView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            ZStack {
                // Outer Ring
                Circle()
                    .stroke(
                        AppTheme.Colors.primary.opacity(0.2),
                        lineWidth: 4
                    )
                    .frame(width: 60, height: 60)
                
                // Animated Ring
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AppTheme.Colors.gradient1,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                
                // Globe Icon
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppTheme.Colors.gradient1)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            Text("Loading...")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .opacity(isAnimating ? 1 : 0.5)
                .animation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}
