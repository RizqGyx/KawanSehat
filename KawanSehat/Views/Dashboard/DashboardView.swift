import SwiftUI

// MARK: - DashboardView
/// Feature 3 Dashboard: Shows BMI, daily calorie needs, meal & workout suggestions
struct DashboardView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color.appBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image("Icon")
                                .resizable()
                                .frame(width: 37, height: 37)
                            Text("KawanSehat")
                                .bold()
                                .font(.system(size: 20))
                                .foregroundStyle(Color.textDark)
                        }
                        .padding(.horizontal)
                        // Greeting with modern design
                        GreetingBanner()
                        
                        // BMI + Calorie Card - Modern style
                        //                        HealthSummaryCard(vm: userProfileVM)
                        
                        // Meal suggestions
                        VStack(alignment: .leading, spacing: 20) {
                            Label("Rekomendasi Makan Hari Ini", systemImage: "fork.knife")
                                .font(.custom("Urbanist-bold", size: 15))
                                .foregroundColor(Color.textDark)
                                .padding(.horizontal)
                            
                            if userProfileVM.mealSuggestions.isEmpty {
                                Text("Tidak ada rekomendasi")
                                    .foregroundStyle(.secondary)
                                    .padding()
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(userProfileVM.mealSuggestions) { food in
                                            MealSuggestionCard(food: food)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Workout suggestions
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Rekomendasi Olahraga Hari Ini!", systemImage: "figure.run")
                                .font(.custom("Urbanist-bold", size: 15))
                                .foregroundColor(Color.textDark)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(userProfileVM.workoutSuggestions) { workout in
                                    WorkoutCard(workout: workout)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK - PREVIEW
#Preview {
    GreetingBanner()
        .environmentObject(UserProfileViewModel())
}
