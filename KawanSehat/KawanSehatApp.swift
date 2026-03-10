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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userProfileVM)
                .environmentObject(notificationService)
                .onAppear {
                    // Track last app open time for smart reminder logic
                    notificationService.recordAppOpen()
                }
        }
    }
}
