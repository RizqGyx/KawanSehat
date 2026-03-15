//
//  SplashScreenView.swift
//  KawanSehat
//
//  Created by Muhammad Rizki on 11/03/26.
//

import SwiftUI

// MARK: - SplashScreenView
/// Splash screen shown on app launch matching design mockup
struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 1
    @State private var subtitleOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            // Warm off-white background matching the image
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Plus/Cross Logo
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                Spacer()
                    .frame(height: 32)
                
                // Main title "KawanSehat"
                Text("KawanSehat")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundStyle(Color.textPrimary)
                    .tracking(0.3)
                    .opacity(1)
                
                Spacer()
                    .frame(height: 6)
                
                // Subtitle "Kesehatan Terintegrasi"
                Text("Kesehatan Terintegrasi")
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundStyle(Color.textPrimary)
                    .opacity(0.5)
                
                Spacer()
                
                // Bottom section
                VStack(spacing: 12) {
                    // Main heading
                    Text("Jaga Kesehatanmu dengan Cerdas")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(1)
                    
                    // Description text
                    Text("Kalkulasi nutrisi, budget, dan reminder cerdas dalam satu aplikasi")
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .opacity(0.5)
                    
                    Spacer()
                        .frame(height: 8)
                    
                    // Progress bar - fully filled
                    Capsule()
                        .fill(Color.textPrimary.opacity(0.8))
                        .frame(height: 5)
                        .opacity(subtitleOpacity)
                    
                    Spacer()
                        .frame(height: 0)
                    
                    // Loading text
                    Text("Memproses...")
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .foregroundStyle(Color.textPrimary)
                        .opacity(0.5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
                titleOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.4)) {
                subtitleOpacity = 1.0
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashScreenView()
}
