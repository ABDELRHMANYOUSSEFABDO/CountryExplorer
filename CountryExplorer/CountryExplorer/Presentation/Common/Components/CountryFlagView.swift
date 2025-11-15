//
//  CountryFlagView.swift
//  CountryExplorer
//
//  Created by Abdelrahman.Youssef on 14/11/2025.
//

import SwiftUI

struct CountryFlagView: View {
    let flagURL: String?
    let size: CGFloat
    let cornerRadius: CGFloat
    
    init(flagURL: String?, size: CGFloat = 50, cornerRadius: CGFloat = 8) {
        self.flagURL = flagURL
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let urlString = flagURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        loadingView
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        fallbackIcon
                    @unknown default:
                        fallbackIcon
                    }
                }
            } else {
                fallbackIcon
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(AppTheme.Colors.textSecondary.opacity(0.2), lineWidth: 1)
        )
        .shadow(
            color: AppTheme.Colors.primary.opacity(0.2),
            radius: 4,
            x: 0,
            y: 2
        )
    }
    
    private var loadingView: some View {
        ZStack {
            AppTheme.Colors.gradient1.opacity(0.3)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
        }
    }
    
    private var fallbackIcon: some View {
        ZStack {
            AppTheme.Colors.gradient1
            
            Image(systemName: "flag.fill")
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Circular Flag Variant
struct CircularCountryFlagView: View {
    let flagURL: String?
    let size: CGFloat
    
    init(flagURL: String?, size: CGFloat = 50) {
        self.flagURL = flagURL
        self.size = size
    }
    
    var body: some View {
        Group {
            if let urlString = flagURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        loadingView
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        fallbackIcon
                    @unknown default:
                        fallbackIcon
                    }
                }
            } else {
                fallbackIcon
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
        )
        .shadow(
            color: AppTheme.Colors.primary.opacity(0.3),
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    private var loadingView: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.gradient1.opacity(0.3))
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
        }
    }
    
    private var fallbackIcon: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.gradient1)
            
            Image(systemName: "flag.fill")
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        // With valid URL
        CountryFlagView(
            flagURL: "https://flagcdn.com/w320/eg.png",
            size: 60
        )
        
        // With circular variant
        CircularCountryFlagView(
            flagURL: "https://flagcdn.com/w320/us.png",
            size: 80
        )
        
        // With nil URL (fallback)
        CountryFlagView(
            flagURL: nil,
            size: 60
        )
        
        // Multiple sizes
        HStack(spacing: 15) {
            CountryFlagView(
                flagURL: "https://flagcdn.com/w320/sa.png",
                size: 40
            )
            CountryFlagView(
                flagURL: "https://flagcdn.com/w320/ae.png",
                size: 50
            )
            CountryFlagView(
                flagURL: "https://flagcdn.com/w320/uk.png",
                size: 60
            )
        }
    }
    .padding()
    .background(AppTheme.Colors.background)
}


