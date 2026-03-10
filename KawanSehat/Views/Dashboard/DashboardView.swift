import SwiftUI

// MARK: - DashboardView
/// Feature 3 Dashboard: Shows BMI, daily calorie needs, meal & workout suggestions
struct DashboardView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Greeting
                    GreetingBanner(name: userProfileVM.profile.name)
                    
                    // BMI + Calorie Card
                    HealthSummaryCard(vm: userProfileVM)
                    
                    // Meal suggestions
                    SectionHeader(title: "Rekomendasi Makan Hari Ini", icon: "fork.knife")
                    
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
                    
                    // Workout suggestions
                    SectionHeader(title: "Olahraga Gratis Untukmu", icon: "figure.run")
                    
                    VStack(spacing: 10) {
                        ForEach(userProfileVM.workoutSuggestions) { workout in
                            WorkoutCard(workout: workout)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .navigationTitle("HealthBudget 💚")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ProfileEditView()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}

// MARK: - Greeting Banner
struct GreetingBanner: View {
    let name: String
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Selamat Pagi"
        case 12..<15: return "Selamat Siang"
        case 15..<18: return "Selamat Sore"
        default:      return "Selamat Malam"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting), \(name)! 👋")
                    .font(.title2.bold())
                Text("Yuk jaga kesehatan hari ini")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Health Summary Card (BMI + Calories)
struct HealthSummaryCard: View {
    let vm: UserProfileViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Top row: BMI + Calories
            HStack(spacing: 0) {
                // BMI
                VStack(spacing: 6) {
                    Text("BMI")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", vm.profile.bmi))
                        .font(.largeTitle.bold())
                        .foregroundColor(vm.bmiColor)
                    Text(vm.profile.bmiCategory)
                        .font(.caption)
                        .foregroundColor(vm.bmiColor)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 60)
                
                // Calorie needs
                VStack(spacing: 6) {
                    Text("Kalori Harian")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f", vm.profile.tdee))
                        .font(.largeTitle.bold())
                        .foregroundColor(.orange)
                    Text("kal / hari")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                Divider().frame(height: 60)
                
                // Budget
                VStack(spacing: 6) {
                    Text("Budget / Makan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Rp\(Int(vm.profile.budgetPerMealIDR))")
                        .font(.title2.bold())
                        .foregroundColor(.blue)
                    Text("per makan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            // Activity level badge
            HStack {
                Label(vm.profile.activityLevel.description, systemImage: "figure.walk.motion")
                    .font(.caption)
                    .foregroundColor(.green)
                Spacer()
                Text("Harris-Benedict Formula")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Meal Suggestion Card (horizontal scroll)
struct MealSuggestionCard: View {
    let food: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Health score indicator
            HStack {
                Text(food.healthScoreLabel)
                    .font(.caption)
                Spacer()
                Text(food.priceFormatted)
                    .font(.caption.bold())
                    .foregroundColor(.green)
            }
            
            Text(food.name)
                .font(.headline)
                .lineLimit(2)
            
            Text("\(Int(food.calories)) kal")
                .font(.subheadline)
                .foregroundColor(.orange)
            
            Text(food.macroSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 160)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 6)
    }
}

// MARK: - Workout Card
struct WorkoutCard: View {
    let workout: WorkoutSuggestion
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: workout.icon)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(workout.name)
                        .font(.subheadline.bold())
                    if workout.isFree {
                        Text("GRATIS")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                }
                Text(workout.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(workout.durationMinutes) min")
                    .font(.caption.bold())
                Text("\(workout.caloriesBurned) kal")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
