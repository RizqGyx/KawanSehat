import SwiftUI

// MARK: - MainTabView
struct MainTabView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var notificationService: NotificationService
    
    // Create child VMs here so they share the same lifecycle as the tab view
    @StateObject private var nutritionVM: NutritionViewModel
    @StateObject private var reminderVM: ReminderViewModel
    
    init() {
        // We can't access @EnvironmentObject in init, so we use a placeholder profile.
        // The NutritionViewModel will be updated in .onAppear with the real profile.
        _nutritionVM = StateObject(wrappedValue: NutritionViewModel(userProfile: UserProfile()))
        _reminderVM = StateObject(wrappedValue: ReminderViewModel(notificationService: NotificationService()))
    }
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Beranda", systemImage: "house.fill")
                }
            
            NutritionView()
                .environmentObject(nutritionVM)
                .tabItem {
                    Label("Nutrisi", systemImage: "fork.knife")
                }
            
            ReminderView()
                .environmentObject(reminderVM)
                .tabItem {
                    Label("Pengingat", systemImage: "bell.fill")
                }
            
            ProfileView()
                .tabItem{
                    Label("Profil", systemImage: "person.circle.fill")
                }
            
        }
        .tint(Color.mainTabTint)
        .onAppear {
            // Sync NutritionVM with current profile
            nutritionVM.updateProfile(userProfileVM.profile)
        }
    }
}

// MARK - PREVIEW
#Preview {
    MainTabView()
        .environmentObject(UserProfileViewModel())
        .environmentObject(NotificationService())
}
