import SwiftUI

// MARK: - RootView
/// Entry point: decides whether to show Onboarding or main Dashboard
struct RootView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    
    var body: some View {
        Group {
            if userProfileVM.profile.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: userProfileVM.profile.hasCompletedOnboarding)
    }
}
