import SwiftUI

// MARK: - DashboardView
/// Feature 3 Dashboard: Shows BMI, daily calorie needs, meal & workout suggestions
struct DashboardView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting with modern design
                    GreetingBanner(name: userProfileVM.profile.name)
                    
                    // BMI + Calorie Card - Modern style
                    HealthSummaryCard(vm: userProfileVM)
                    
                    // Meal suggestions
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Rekomendasi Makan Hari Ini", systemImage: "fork.knife")
                            .font(.headline)
                            .foregroundColor(.blue)
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
                        Label("Olahraga Gratis Untukmu", systemImage: "figure.run")
                            .font(.headline)
                            .foregroundColor(.blue)
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
                .padding(.top)
            }
            .navigationTitle("Kawan Sehat")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ProfileEditView()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("\(greeting), \(name)! 👋")
                .font(.title2.bold())
            Text("Yuk jaga kesehatan hari ini")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Health Summary Card (BMI + Calories) - Modern Style
struct HealthSummaryCard: View {
    let vm: UserProfileViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Top section: BMI & Calories in modern layout
            HStack(spacing: 12) {
                // BMI Card
                VStack(spacing: 8) {
                    Text("BMI")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", vm.profile.bmi))
                        .font(.title.bold())
                        .foregroundColor(vm.bmiColor)
                    Text(vm.profile.bmiCategory)
                        .font(.caption2)
                        .foregroundColor(vm.bmiColor)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4)
                
                // Calories Card
                VStack(spacing: 8) {
                    Text("Kalori Harian")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f", vm.profile.tdee))
                        .font(.title.bold())
                        .foregroundColor(.orange)
                    Text("kal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4)
            }
            
            // Budget info
            HStack(spacing: 12) {
                Label("Budget per Makan", systemImage: "banknote")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Rp\(Int(vm.profile.budgetPerMealIDR))")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Activity level
            HStack(spacing: 8) {
                Image(systemName: "figure.walk.motion")
                    .foregroundColor(.blue)
                Text(vm.profile.activityLevel.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Meal Suggestion Card
struct MealSuggestionCard: View {
    let food: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(food.healthScoreLabel)
                    .font(.caption.bold())
                    .foregroundColor(.blue)
                Spacer()
                Text(food.priceFormatted)
                    .font(.caption.bold())
                    .foregroundColor(.green)
            }
            
            Text(food.name)
                .font(.subheadline.bold())
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Label("\(Int(food.calories))", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text(food.category.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 160)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.08), Color.purple.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

// MARK: - Workout Card - Modern Style
struct WorkoutCard: View {
    let workout: WorkoutSuggestion
    
    var body: some View {
        HStack(spacing: 12) {
            // Modern icon background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: workout.icon)
                    .foregroundColor(.blue)
                    .font(.subheadline.bold())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(workout.name)
                        .font(.subheadline.bold())
                    if workout.isFree {
                        Text("GRATIS")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                }
                Text(workout.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Label("\(workout.durationMinutes) m", systemImage: "clock.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Label("\(workout.caloriesBurned)", systemImage: "flame.fill")
                    .font(.caption2)
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
