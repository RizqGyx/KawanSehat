//
//  SplashScreenView.swift
//  KawanSehat
//
//  Created by Muhammad Rizki on 11/03/26.
//

import SwiftUI

// MARK: - SplashScreenView
/// Animated splash screen shown on app launch
struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showProgress = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.3),  // Dark green
                    Color(red: 0.4, green: 0.7, blue: 0.5)   // Light green
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated elements
            VStack(spacing: 30) {
                Spacer()
                
                // Logo / App Icon with animation
                VStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.5)
                    
                    VStack(spacing: 8) {
                        Text("KawanSehat")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("Kesehatan Terintegrasi")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .opacity(isAnimating ? 1.0 : 0.0)
                
                Spacer()
                
                // Bottom section with tagline and progress
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("💚 Jaga Kesehatanmu dengan Cerdas")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Kalkulasi nutrisi, budget, dan reminder cerdas dalam satu aplikasi")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                    
                    // Progress indicator
                    if showProgress {
                        VStack(spacing: 12) {
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white)
                                    .frame(height: 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .scaleEffect(x: isAnimating ? 1.0 : 0.0, anchor: .leading)
                            }
                            .frame(height: 4)
                            .padding(.horizontal, 40)
                            
                            Text("Memproses...")
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showProgress = true
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashScreenView()
}
