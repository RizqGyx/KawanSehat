//
//  KawanSehatApp.swift
//  KawanSehat
//
//  Created by Muhammad Rizki on 10/03/26.
//

import SwiftUI

@main
struct KawanSehatApp: App {
    @StateObject private var userProfileVM = UserProfileViewModel()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var geminiService = GeminiService.shared
    
    @State private var isSplashScreenVisible = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main app content
                RootView()
                    .environmentObject(userProfileVM)
                    .environmentObject(notificationService)
                    .environmentObject(geminiService)
                    .onAppear {
                        // Load Gemini suggestion history (no permission needed)
                        geminiService.loadHistory()
                        
                        // Request notification permission and setup meal reminders
                        Task {
                            // Request permission first
                            await notificationService.requestPermission()
                            
                            // Check the new status
                            await notificationService.checkAuthorizationStatus()
                            
                            // Now that we have permission, record app open and schedule reminders
                            notificationService.recordAppOpen()
                            
                            // Schedule meal reminders
                            if notificationService.isAuthorized {
                                notificationService.scheduleMealReminders(userProfile: userProfileVM.profile)
                                
                                // Generate meal recommendations for upcoming meals
                                await notificationService.generateUpcomingMealRecommendations(
                                    userProfile: userProfileVM.profile,
                                    geminiService: geminiService
                                )
                            } else {
                                print("⚠️ Notification permission was denied")
                            }
                        }
                    }
                
                // Splash screen overlay
                if isSplashScreenVisible {
                    SplashScreenView()
                        .transition(.opacity)
                        .onAppear {
                            // Hide splash screen after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isSplashScreenVisible = false
                                }
                            }
                        }
                }
            }
        }
    }
}

