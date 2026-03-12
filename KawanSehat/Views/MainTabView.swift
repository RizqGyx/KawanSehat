import SwiftUI
import Combine

// MARK: - MainTabView
struct MainTabView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var notificationService: NotificationService
    
    // Create child VMs here so they share the same lifecycle as the tab view
    @StateObject private var nutritionVM: NutritionViewModel
    @StateObject private var reminderVM: ReminderViewModel
    @StateObject private var waterVM: WaterViewModel
    @StateObject private var budgetVM: BudgetViewModel
    @StateObject private var questVM: QuestViewModel
    
    init() {
        // We can't access @EnvironmentObject in init, so we use a placeholder profile.
        // The ViewModels will be updated in .onAppear with the real profile.
        _nutritionVM = StateObject(wrappedValue: NutritionViewModel(userProfile: UserProfile()))
        _reminderVM = StateObject(wrappedValue: ReminderViewModel(notificationService: NotificationService()))
        _waterVM = StateObject(wrappedValue: WaterViewModel(userProfile: UserProfile()))
        _budgetVM = StateObject(wrappedValue: BudgetViewModel(userProfile: UserProfile()))
        _questVM = StateObject(wrappedValue: QuestViewModel())
    }
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(nutritionVM)
                .environmentObject(budgetVM)
                .environmentObject(questVM)
                .tabItem {
                    Label("Beranda", systemImage: "house.fill")
                }
            
            MakanView()
                .environmentObject(nutritionVM)
                .environmentObject(userProfileVM)
                .tabItem {
                    Label("Makan", systemImage: "fork.knife")
                }
            
            WaterView()
                .environmentObject(waterVM)
                .environmentObject(userProfileVM)
                .tabItem {
                    Label("Air Minum", systemImage: "drop.fill")
                }
            
            SleepView()
                .tabItem {
                    Label("Tidur", systemImage: "moon.stars.fill")
                }
            
            WorkoutView()
                .tabItem {
                    Label("Olahraga", systemImage: "dumbbell.fill")
                }
            
            BudgetView()
                .environmentObject(budgetVM)
                .environmentObject(userProfileVM)
                .tabItem {
                    Label("Anggaran", systemImage: "wallet.pass.fill")
                }
        }
        .tint(.blue)
        .onAppear {
            // Sync VMs with current profile
            nutritionVM.updateProfile(userProfileVM.profile)
            waterVM.updateProfile(userProfileVM.profile)
            budgetVM.updateProfile(userProfileVM.profile)
        }
    }
}

