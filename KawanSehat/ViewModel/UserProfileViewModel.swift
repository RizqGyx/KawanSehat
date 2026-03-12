import Foundation
import SwiftUI
import Combine

// MARK: - UserProfileViewModel
/// ViewModel for Feature 3: Health Data Input + Personalized Suggestions.
/// This is the central ViewModel that feeds data into Features 1 and 2.
@MainActor
class UserProfileViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var profile: UserProfile
    @Published var workoutSuggestions: [WorkoutSuggestion] = []
    @Published var mealSuggestions: [FoodItem] = []
    
    // MARK: - Form state (used during onboarding)
    @Published var formName: String = ""
    @Published var formAge: String = "25"
    @Published var formGender: Gender = .male
    @Published var formWeight: String = "65"
    @Published var formHeight: String = "165"
    @Published var formActivity: ActivityLevel = .moderate
    @Published var formBudget: String = "50000"
    @Published var formMonthlyBudget: String = "1500000"
    @Published var formDietaryPreference: DietaryPreference = .regular
    
    @Published var showValidationError: Bool = false
    @Published var validationMessage: String = ""
    
    private let storage = UserDefaultsService.shared
    
    init() {
        // Load saved profile or use empty default
        self.profile = storage.loadProfile() ?? UserProfile()
        generateSuggestions()
    }
    
    // MARK: - Validation
    var isFormValid: Bool {
        guard !formName.trimmingCharacters(in: .whitespaces).isEmpty,
              let age = Int(formAge), age > 0 && age < 120,
              let weight = Double(formWeight), weight > 20 && weight < 300,
              let height = Double(formHeight), height > 100 && height < 250,
              let budget = Double(formBudget), budget > 0,
              let monthlyBudget = Double(formMonthlyBudget), monthlyBudget > 0 else {
            return false
        }
        return true
    }
    
    // MARK: - Save Profile from Onboarding Form
    func saveProfile() {
        guard isFormValid else {
            showValidationError = true
            validationMessage = "Mohon isi semua data dengan benar"
            return
        }
        
        profile.name = formName.trimmingCharacters(in: .whitespaces)
        profile.age = Int(formAge) ?? 25
        profile.gender = formGender
        profile.weightKg = Double(formWeight) ?? 65
        profile.heightCm = Double(formHeight) ?? 165
        profile.activityLevel = formActivity
        profile.dailyBudgetIDR = Double(formBudget) ?? 50000
        profile.monthlyBudgetIDR = Double(formMonthlyBudget) ?? 1500000
        profile.dietaryPreference = formDietaryPreference
        profile.hasCompletedOnboarding = true
        
        // Calculate and cache TDEE, BMR, macros, and water goal
        profile.cachedTDEE = profile.tdee
        profile.cachedBMR = profile.bmr
        profile.waterGoalL = profile.calculatedWaterGoalL
        
        // Calculate daily macro targets (balanced nutrition)
        // Protein: 25% of TDEE / 4 kcal per gram
        profile.proteinTargetG = (profile.tdee * 0.25) / 4.0
        // Carbs: 50% of TDEE / 4 kcal per gram
        profile.carbsTargetG = (profile.tdee * 0.50) / 4.0
        // Fat: 25% of TDEE / 9 kcal per gram
        profile.fatTargetG = (profile.tdee * 0.25) / 9.0
        
        storage.saveProfile(profile)
        generateSuggestions()
    }
    
    // MARK: - Generate Personalized Suggestions
    func generateSuggestions() {
        // Meal suggestions based on budget and calorie needs
        mealSuggestions = FoodDatabase.shared.suggestMeals(
            calorieBudget: profile.tdee,
            priceBudget: profile.dailyBudgetIDR
        )
        
        // Workout suggestions based on activity level and BMI
        workoutSuggestions = WorkoutRecommendationEngine.suggestions(for: profile)
    }
    
    // MARK: - Update existing profile
    func updateProfile() {
        storage.saveProfile(profile)
        generateSuggestions()
    }
    
    // MARK: - BMI Color for UI
    var bmiColor: Color {
        switch profile.bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return Color.orange
        default: return .red
        }
    }
    
    // MARK: - Calorie progress (example: 1500 consumed of 2000 target)
    var calorieProgressExample: Double {
        return 0.65  // Placeholder for MVP — replace with actual food log data
    }
}

// MARK: - Workout Suggestion Model
struct WorkoutSuggestion: Identifiable {
    let id = UUID()
    let name: String
    let durationMinutes: Int
    let caloriesBurned: Int
    let difficulty: String
    let icon: String
    let isFree: Bool
    let description: String
}

// MARK: - Workout Recommendation Engine
struct WorkoutRecommendationEngine {
    
    static func suggestions(for profile: UserProfile) -> [WorkoutSuggestion] {
        var suggestions: [WorkoutSuggestion] = []
        
        // Cardio recommendations based on BMI
        if profile.bmi > 25 {
            suggestions.append(WorkoutSuggestion(
                name: "Jalan Cepat",
                durationMinutes: 30,
                caloriesBurned: 150,
                difficulty: "Mudah",
                icon: "figure.walk",
                isFree: true,
                description: "Jalan cepat 30 menit di sekitar rumah. Mulai pagi hari sebelum sarapan."
            ))
            suggestions.append(WorkoutSuggestion(
                name: "Bersepeda",
                durationMinutes: 45,
                caloriesBurned: 200,
                difficulty: "Mudah",
                icon: "figure.outdoor.cycle",
                isFree: true,
                description: "Bersepeda santai di area sekitar. Baik untuk sendi."
            ))
        }
        
        // Strength recommendations
        suggestions.append(WorkoutSuggestion(
            name: "Push-up & Squat",
            durationMinutes: 20,
            caloriesBurned: 100,
            difficulty: "Sedang",
            icon: "figure.strengthtraining.traditional",
            isFree: true,
            description: "3 set push-up (10 reps) + 3 set squat (15 reps). Tanpa alat, bisa di rumah."
        ))
        
        // Yoga / stretching for sedentary users
        if profile.activityLevel == .sedentary || profile.activityLevel == .light {
            suggestions.append(WorkoutSuggestion(
                name: "Yoga Pagi",
                durationMinutes: 15,
                caloriesBurned: 60,
                difficulty: "Mudah",
                icon: "figure.mind.and.body",
                isFree: true,
                description: "Peregangan dan yoga ringan 15 menit setiap pagi. Ikuti video YouTube gratis."
            ))
        }
        
        // Running for active users
        if profile.activityLevel == .moderate || profile.activityLevel == .active {
            suggestions.append(WorkoutSuggestion(
                name: "Jogging",
                durationMinutes: 30,
                caloriesBurned: 250,
                difficulty: "Sedang",
                icon: "figure.run",
                isFree: true,
                description: "Jogging 30 menit dengan kecepatan sedang. Lakukan 3x seminggu."
            ))
        }
        
        // Core workout
        suggestions.append(WorkoutSuggestion(
            name: "Plank & Core",
            durationMinutes: 10,
            caloriesBurned: 50,
            difficulty: "Sedang",
            icon: "figure.core.training",
            isFree: true,
            description: "3 set plank (30 detik) + sit-up (15 reps). Bagus untuk postur tubuh."
        ))
        
        return suggestions
    }
}
