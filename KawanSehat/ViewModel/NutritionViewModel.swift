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
    
    private var userProfile: UserProfile
    private let db = FoodDatabase.shared
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        // Show all foods by default
        searchResults = db.allFoods
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
}
