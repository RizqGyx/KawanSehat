import SwiftUI

// MARK: - DashboardView
/// Feature 3 Dashboard: Shows BMI, daily calorie needs, meal & workout suggestions
struct DashboardView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var budgetVM: BudgetViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting with modern design
                    GreetingBanner(name: userProfileVM.profile.name)
                    
                    // BMI + Calorie Card - Modern style
                    HealthSummaryCard(vm: userProfileVM)
                    
                    // Daily Calorie Tracker Widget
                    DailyCalorieWidget(tdee: userProfileVM.profile.cachedTDEE)
                    
                    // Budget Tracker Widget
                    BudgetTrackerWidget(dailyBudget: userProfileVM.profile.dailyBudgetIDR)
                    
                    // Macro Trackers
                    MacroTrackersWidget(
                        proteinTarget: userProfileVM.profile.proteinTargetG,
                        carbsTarget: userProfileVM.profile.carbsTargetG,
                        fatTarget: userProfileVM.profile.fatTargetG
                    )
                    
                    // Water Intake Widget
                    WaterIntakeWidget(waterGoal: userProfileVM.profile.waterGoalL)
                    
                    // Health Score Ring
                    HealthScoreWidget()
                    
                    // Sleep Tracker Widget
                    SleepTrackerWidget()
                    
                    // Workout Summary Widget
                    WorkoutSummaryWidget()
                    
                    // Active Quests Widget
                    ActiveQuestsWidget()
                    
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
                    Text(workout.difficulty)
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

// MARK: - Daily Calorie Tracker Widget
struct DailyCalorieWidget: View {
    let tdee: Double
    @EnvironmentObject var nutritionVM: NutritionViewModel
    
    var consumedCalories: Double {
        nutritionVM.todayTotalCalories
    }
    
    var progress: Double {
        guard tdee > 0 else { return 0 }
        return min(consumedCalories / tdee, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Kalori Harian", systemImage: "flame.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
                Spacer()
                Text("\(Int(consumedCalories))/\(Int(tdee)) kal")
                    .font(.caption.bold())
            }
            
            ProgressView(value: progress)
                .tint(.orange)
            
            HStack {
                Text("Sisa: \(Int(max(0, tdee - consumedCalories))) kal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Budget Tracker Widget
struct BudgetTrackerWidget: View {
    let dailyBudget: Double
    @EnvironmentObject var nutritionVM: NutritionViewModel
    
    var spentToday: Double {
        nutritionVM.todayTotalFoodSpent
    }
    
    var progress: Double {
        guard dailyBudget > 0 else { return 0 }
        return min(spentToday / dailyBudget, 1.0)
    }
    
    var progressColor: Color {
        if progress < 0.5 {
            return .green
        } else if progress < 0.8 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Budget Makanan Hari Ini", systemImage: "creditcard.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
                Spacer()
                Text("Rp\(Int(spentToday))/Rp\(Int(dailyBudget))")
                    .font(.caption.bold())
            }
            
            ProgressView(value: progress)
                .tint(progressColor)
            
            HStack {
                Text("Sisa: Rp\(Int(max(0, dailyBudget - spentToday)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Macro Trackers Widget
struct MacroTrackersWidget: View {
    let proteinTarget: Double
    let carbsTarget: Double
    let fatTarget: Double
    @EnvironmentObject var nutritionVM: NutritionViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Label("Makro Hari Ini", systemImage: "list.bullet.rectangle")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                MacroMiniCard(
                    label: "Protein",
                    consumed: String(format: "%.0f", nutritionVM.todayTotalProteinG),
                    target: String(format: "%.0f", proteinTarget),
                    icon: "bolt.fill",
                    color: .red
                )
                
                MacroMiniCard(
                    label: "Karbo",
                    consumed: String(format: "%.0f", nutritionVM.todayTotalCarbsG),
                    target: String(format: "%.0f", carbsTarget),
                    icon: "bolt.fill",
                    color: .blue
                )
                
                MacroMiniCard(
                    label: "Lemak",
                    consumed: String(format: "%.0f", nutritionVM.todayTotalFatG),
                    target: String(format: "%.0f", fatTarget),
                    icon: "bolt.fill",
                    color: .yellow
                )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Macro Mini Card
struct MacroMiniCard: View {
    let label: String
    let consumed: String
    let target: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            Text(label)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            HStack(spacing: 2) {
                Text(consumed)
                    .font(.subheadline.bold())
                    .foregroundColor(color)
                Text("/\(target)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text("g")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Water Intake Widget
struct WaterIntakeWidget: View {
    let waterGoal: Double
    @EnvironmentObject var waterVM: WaterViewModel
    
    var waterConsumed: Double {
        waterVM.todayTotal / 1000.0  // Convert from ml to liters
    }
    
    var progress: Double {
        guard waterGoal > 0 else { return 0 }
        return min(waterConsumed / waterGoal, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Air Minum", systemImage: "drop.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                Spacer()
                Text("\(String(format: "%.1f", waterConsumed))/\(String(format: "%.1f", waterGoal)) L")
                    .font(.caption.bold())
            }
            
            ProgressView(value: progress)
                .tint(.blue)
            
            HStack(spacing: 8) {
                Button(action: { waterVM.addWater(amount: 250) }) {
                    Label("+250ml", systemImage: "drop.fill")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Button(action: { waterVM.addWater(amount: 500) }) {
                    Label("+500ml", systemImage: "drop.fill")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Health Score Widget
struct HealthScoreWidget: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var budgetVM: BudgetViewModel
    @EnvironmentObject var sleepVM: SleepViewModel
    @EnvironmentObject var workoutVM: WorkoutViewModel
    
    private let healthScoreService = HealthScoreService.shared
    
    var nutritionScore: Double {
        healthScoreService.nutritionScore(
            consumedCalories: nutritionVM.todayTotalCalories,
            targetCalories: userProfileVM.profile.cachedTDEE,
            consumedProtein: nutritionVM.todayTotalProteinG,
            targetProtein: userProfileVM.profile.proteinTargetG,
            consumedCarbs: nutritionVM.todayTotalCarbsG,
            targetCarbs: userProfileVM.profile.carbsTargetG,
            consumedFat: nutritionVM.todayTotalFatG,
            targetFat: userProfileVM.profile.fatTargetG
        )
    }
    
    var sleepScore: Double {
        healthScoreService.sleepScore(averageSleepHours: sleepVM.averageSleepHours)
    }
    
    var workoutScore: Double {
        healthScoreService.workoutScore(
            weeklyWorkoutCount: workoutVM.thisWeekCount,
            weeklyCaloriesBurned: workoutVM.thisWeekCaloriesBurned
        )
    }
    
    var budgetScore: Double {
        healthScoreService.budgetScore(
            spent: budgetVM.totalSpentThisMonth,
            budget: budgetVM.monthlyBudget
        )
    }
    
    var compositeScore: Int {
        healthScoreService.compositeHealthScore(
            nutritionScore: nutritionScore,
            sleepScore: sleepScore,
            workoutScore: workoutScore,
            budgetScore: budgetScore
        )
    }
    
    var scoreColor: Color {
        switch compositeScore {
        case 80...: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Label("Skor Kesehatan", systemImage: "heart.fill")
                .font(.subheadline.bold())
                .foregroundColor(scoreColor)
            
            HStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: Double(compositeScore) / 100.0)
                        .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(compositeScore)")
                            .font(.title.bold())
                            .foregroundColor(scoreColor)
                        Text("dari 100")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 100, height: 100)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Nutrisi")
                            .font(.caption)
                        Spacer()
                        Text("\(Int(nutritionScore))")
                            .font(.caption.bold())
                            .foregroundColor(.red.opacity(0.7))
                    }
                    HStack {
                        Text("Tidur")
                            .font(.caption)
                        Spacer()
                        Text("\(Int(sleepScore))")
                            .font(.caption.bold())
                            .foregroundColor(.indigo.opacity(0.7))
                    }
                    HStack {
                        Text("Olahraga")
                            .font(.caption)
                        Spacer()
                        Text("\(Int(workoutScore))")
                            .font(.caption.bold())
                            .foregroundColor(.purple.opacity(0.7))
                    }
                    HStack {
                        Text("Budget")
                            .font(.caption)
                        Spacer()
                        Text("\(Int(budgetScore))")
                            .font(.caption.bold())
                            .foregroundColor(.green.opacity(0.7))
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(scoreColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Sleep Tracker Widget
struct SleepTrackerWidget: View {
    @EnvironmentObject var sleepVM: SleepViewModel
    
    var lastNightSleep: Double {
        sleepVM.last7DaysSleep.first?.durationHours ?? 0
    }
    
    var lastNightQuality: String {
        guard let lastLog = sleepVM.last7DaysSleep.first else { return "Belum ada" }
        return lastLog.quality.rawValue
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Tidur Malam Lalu", systemImage: "moon.stars.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.indigo)
                Spacer()
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Durasi")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(lastNightSleep > 0 ? "\(String(format: "%.1f", lastNightSleep)) jam" : "Belum ada")
                        .font(.headline.bold())
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Kualitas")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(lastNightQuality)
                        .font(.subheadline.bold())
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.indigo.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .onAppear {
            sleepVM.getGeminiAdvice()
        }
    }
}

// MARK: - Workout Summary Widget
struct WorkoutSummaryWidget: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Status Olahraga", systemImage: "figure.stairs")
                    .font(.subheadline.bold())
                    .foregroundColor(.purple)
                Spacer()
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hari Ini")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: workoutVM.hasWorkoutToday ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(workoutVM.hasWorkoutToday ? .green : .gray)
                        Text(workoutVM.hasWorkoutToday ? "Sudah" : "Belum")
                            .font(.subheadline.bold())
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Minggu Ini")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(workoutVM.thisWeekCount)x olahraga")
                        .font(.subheadline.bold())
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Active Quests Widget
struct ActiveQuestsWidget: View {
    @EnvironmentObject var questVM: QuestViewModel
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var budgetVM: BudgetViewModel
    @StateObject private var waterVM = WaterViewModel(userProfile: UserProfile())
    @StateObject private var sleepVM = SleepViewModel()
    @StateObject private var workoutVM = WorkoutViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Misi Aktif", systemImage: "flag.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("\(questVM.completedQuestCount)/\(questVM.todayQuests.count)")
                    .font(.caption.bold())
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            if questVM.activeQuests.isEmpty && questVM.completedQuestCount > 0 {
                Text("Semua misi sudah selesai! 🎉")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if questVM.todayQuests.isEmpty {
                Text("Tidak ada misi hari ini")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(questVM.activeQuests) { quest in
                        QuestRow(quest: quest)
                    }
                }
                .padding()
            }
        }
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .onAppear {
            updateQuestProgress()
        }
    }
    
    private func updateQuestProgress() {
        let water2L = waterVM.todayTotal >= 2000  // 2L in ml
        let threeeMeals = nutritionVM.todayMealLogs.count >= 3
        let workout30Min = workoutVM.todayWorkouts.filter { $0.durationMinutes >= 30 }.count > 0
        let sleep7Hours = sleepVM.averageSleepHours >= 7
        let stayInBudget = budgetVM.totalSpentThisMonth <= budgetVM.monthlyBudget
        
        questVM.checkAndUpdateQuests(
            water2LDrunk: water2L,
            threeeMealsLogged: threeeMeals,
            workout30MinDone: workout30Min,
            sleep7HoursDone: sleep7Hours,
            stayInBudget: stayInBudget
        )
    }
}

// MARK: - Quest Row
struct QuestRow: View {
    let quest: Quest
    
    var body: some View {
        HStack {
            Image(systemName: quest.type.icon)
                .foregroundColor(.green)
                .frame(width: 24)
            
            Text(quest.type.description)
                .font(.subheadline)
            
            Spacer()
            
            Badge(text: "+\(quest.type.reward) XP", color: .green)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Badge Component
struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
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
