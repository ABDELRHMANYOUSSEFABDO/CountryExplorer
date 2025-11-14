//
//  SplashView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background Gradient
            AppTheme.Colors.gradient1
                .ignoresSafeArea()
            
            // Animated Circles
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        Color.white.opacity(0.2),
                        lineWidth: 2
                    )
                    .frame(
                        width: 100 + CGFloat(index * 50),
                        height: 100 + CGFloat(index * 50)
                    )
                    .scaleEffect(isAnimating ? 1.5 : 0.5)
                    .opacity(isAnimating ? 0 : 0.5)
                    .animation(
                        Animation.easeOut(duration: 2.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.3),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: AppTheme.Spacing.lg) {
                // Logo/Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .blur(radius: 10)
                    
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(rotation))
                }
                .scaleEffect(scale)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                
                // App Name
                VStack(spacing: AppTheme.Spacing.xs) {
                    Text("Country Explorer")
                        .font(AppTheme.Typography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Discover the World")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(opacity)
                
                // Loading Indicator
                LoadingDotsView()
                    .opacity(opacity)
                    .padding(.top, AppTheme.Spacing.lg)
            }
        }
        .onAppear {
            withAnimation(AppTheme.Animation.spring.delay(0.2)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(
                Animation.linear(duration: 20)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            isAnimating = true
        }
    }
}

// MARK: - Loading Dots
struct LoadingDotsView: View {
    @State private var animateOne = false
    @State private var animateTwo = false
    @State private var animateThree = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white)
                .frame(width: 12, height: 12)
                .scaleEffect(animateOne ? 1.0 : 0.5)
                .opacity(animateOne ? 1.0 : 0.5)
            
            Circle()
                .fill(Color.white)
                .frame(width: 12, height: 12)
                .scaleEffect(animateTwo ? 1.0 : 0.5)
                .opacity(animateTwo ? 1.0 : 0.5)
            
            Circle()
                .fill(Color.white)
                .frame(width: 12, height: 12)
                .scaleEffect(animateThree ? 1.0 : 0.5)
                .opacity(animateThree ? 1.0 : 0.5)
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
            ) {
                animateOne.toggle()
            }
            
            withAnimation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(0.2)
            ) {
                animateTwo.toggle()
            }
            
            withAnimation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(0.4)
            ) {
                animateThree.toggle()
            }
        }
    }
}

