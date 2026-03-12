import Foundation
import SwiftUI
import Combine

// MARK: - NutritionViewModel
/// ViewModel for Feature 1: Nutrition Calculator + Food Suggester
@MainActor
class NutritionViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var searchQuery: String = ""
    @Published var searchResults: [FoodItem] = []
    @Published var selectedFood: FoodItem? = nil
    @Published var suggestions: [FoodSuggestion] = []
    @Published var isSearching: Bool = false
    @Published var mealLogs: [MealLog] = []
    
    private var userProfile: UserProfile
    private let db = FoodDatabase.shared
    private let storage = UserDefaultsService.shared
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        // Show all foods by default
        searchResults = db.allFoods
        loadMealLogs()
    }
    
    // MARK: - Update user profile reference (when profile changes)
    func updateProfile(_ profile: UserProfile) {
        self.userProfile = profile
        // Recalculate suggestions if a food is selected
        if let food = selectedFood {
            loadSuggestions(for: food)
        }
    }
    
    // MARK: - Search
    func performSearch() {
        isSearching = true
        // Slight delay to feel like real search
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.searchResults = self.db.search(query: self.searchQuery)
            self.isSearching = false
        }
    }
    
    // MARK: - Select Food and Load Suggestions
    func selectFood(_ food: FoodItem) {
        selectedFood = food
        loadSuggestions(for: food)
    }
    
    func clearSelection() {
        selectedFood = nil
        suggestions = []
    }
    
    // MARK: - Load healthier/cheaper suggestions
    private func loadSuggestions(for food: FoodItem) {
        suggestions = db.suggestions(for: food, budget: userProfile.budgetPerMealIDR)
    }
    
    // MARK: - Calorie percentage of daily needs
    func caloriePercentage(for food: FoodItem) -> Double {
        guard userProfile.tdee > 0 else { return 0 }
        return min(food.calories / userProfile.tdee, 1.0)
    }
    
    // MARK: - Whether food fits user budget per meal
    func fitsbudget(_ food: FoodItem) -> Bool {
        return food.priceIDR <= userProfile.budgetPerMealIDR
    }
    
    // MARK: - Budget remaining after selection
    var budgetRemainingAfterSelection: Double {
        guard let food = selectedFood else { return userProfile.budgetPerMealIDR }
        return userProfile.budgetPerMealIDR - food.priceIDR
    }
    
    var budgetRemainingFormatted: String {
        let remaining = budgetRemainingAfterSelection
        if remaining >= 0 {
            return "Sisa budget: Rp\(Int(remaining))"
        } else {
            return "Melebihi budget: Rp\(Int(abs(remaining)))"
        }
    }
    
    // MARK: - Meal Logging
    
    /// Add a new meal log
    func addMealLog(
        foodName: String,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        calories: Double,
        priceIDR: Double
    ) {
        let newLog = MealLog(
            foodName: foodName,
            proteinG: proteinG,
            carbsG: carbsG,
            fatG: fatG,
            calories: calories,
            priceIDR: priceIDR
        )
        mealLogs.insert(newLog, at: 0)
        saveMealLogs()
    }
    
    /// Remove a meal log
    func removeMealLog(_ log: MealLog) {
        mealLogs.removeAll { $0.id == log.id }
        saveMealLogs()
    }
    
    /// Get today's meal logs
    var todayMealLogs: [MealLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return mealLogs.filter { log in
            calendar.isDate(log.date, inSameDayAs: today)
        }
    }
    
    /// Calculate total macros for today
    var todayTotalProteinG: Double {
        todayMealLogs.reduce(0) { $0 + $1.proteinG }
    }
    
    var todayTotalCarbsG: Double {
        todayMealLogs.reduce(0) { $0 + $1.carbsG }
    }
    
    var todayTotalFatG: Double {
        todayMealLogs.reduce(0) { $0 + $1.fatG }
    }
    
    var todayTotalCalories: Double {
        todayMealLogs.reduce(0) { $0 + $1.calories }
    }
    
    var todayTotalFoodSpent: Double {
        todayMealLogs.reduce(0) { $0 + $1.priceIDR }
    }
    
    /// Format total food spent
    var todayFoodSpentFormatted: String {
        return "Rp\(Int(todayTotalFoodSpent))"
    }
    
    /// Protein percentage of daily target
    func proteinPercentage() -> Double {
        guard userProfile.proteinTargetG > 0 else { return 0 }
        return min(todayTotalProteinG / userProfile.proteinTargetG, 1.0)
    }
    
    /// Carbs percentage of daily target
    func carbsPercentage() -> Double {
        guard userProfile.carbsTargetG > 0 else { return 0 }
        return min(todayTotalCarbsG / userProfile.carbsTargetG, 1.0)
    }
    
    /// Fat percentage of daily target
    func fatPercentage() -> Double {
        guard userProfile.fatTargetG > 0 else { return 0 }
        return min(todayTotalFatG / userProfile.fatTargetG, 1.0)
    }
    
    // MARK: - Persistence
    
    private func loadMealLogs() {
        mealLogs = storage.loadMealLogs()
    }
    
    private func saveMealLogs() {
        storage.saveMealLogs(mealLogs)
    }
}
