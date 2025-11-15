//
//  ViewExtensions.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

extension View {
    /// Add haptic feedback on tap
    func hapticFeedback(
        style: UIImpactFeedbackGenerator.FeedbackStyle = .light
    ) -> some View {
        self.onTapGesture {
            HapticManager.shared.impact(style)
        }
    }
    
    /// Add a shimmer loading effect
    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
    
    /// Add a fade in animation
    func fadeIn(duration: Double = 0.3, delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(duration: duration, delay: delay))
    }
    
    /// Add a slide in animation
    func slideIn(
        edge: Edge = .leading,
        duration: Double = 0.3,
        delay: Double = 0
    ) -> some View {
        self.modifier(SlideInModifier(edge: edge, duration: duration, delay: delay))
    }
}

// MARK: - Shimmer Modifier
struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isActive {
                        AppTheme.Colors.shimmerGradient
                            .frame(width: geometry.size.width)
                            .offset(x: phase * geometry.size.width)
                            .blendMode(.overlay)
                    }
                }
            )
            .onAppear {
                if isActive {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            }
    }
}

// MARK: - Fade In Modifier
struct FadeInModifier: ViewModifier {
    let duration: Double
    let delay: Double
    
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - Slide In Modifier
struct SlideInModifier: ViewModifier {
    let edge: Edge
    let duration: Double
    let delay: Double
    
    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: edge == .leading ? -offset : (edge == .trailing ? offset : 0),
                y: edge == .top ? -offset : (edge == .bottom ? offset : 0)
            )
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                    .delay(delay)
                ) {
                    offset = 0
                    opacity = 1
                }
            }
    }
}


