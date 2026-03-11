//
//  MealReminderHistory.swift
//  KawanSehat
//
//  Created by Muhammad Rizki on 11/03/26.
//

import Foundation

// MARK: - Meal Reminder History
struct MealReminderHistoryItem: Identifiable, Codable {
    let id: UUID
    let mealType: MealRecommendation.MealType
    let foodName: String
    let description: String
    let calorieInfo: String
    let budgetInfo: String
    let timestamp: Date
    let userProfile: UserProfile
    
    init(
        mealType: MealRecommendation.MealType,
        recommendation: MealRecommendation,
        userProfile: UserProfile
    ) {
        self.id = UUID()
        self.mealType = mealType
        self.foodName = recommendation.foodName
        self.description = recommendation.description
        self.calorieInfo = recommendation.calorieInfo
        self.budgetInfo = recommendation.budgetInfo
        self.timestamp = Date()
        self.userProfile = userProfile
    }
}

// MARK: - UserDefaultsService Extension for Meal History
extension UserDefaultsService {
    
    private static let MEAL_REMINDER_HISTORY_KEY = "meal_reminder_history"
    
    func saveMealReminderHistory(_ items: [MealReminderHistoryItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: Self.MEAL_REMINDER_HISTORY_KEY)
        }
    }
    
    func loadMealReminderHistory() -> [MealReminderHistoryItem] {
        guard let data = UserDefaults.standard.data(forKey: Self.MEAL_REMINDER_HISTORY_KEY),
              let decoded = try? JSONDecoder().decode([MealReminderHistoryItem].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func addMealReminderHistoryItem(_ item: MealReminderHistoryItem) {
        var history = loadMealReminderHistory()
        history.insert(item, at: 0)  // Add to front (newest first)
        
        // Keep only last 50 items
        if history.count > 50 {
            history = Array(history.prefix(50))
        }
        
        saveMealReminderHistory(history)
    }
    
    func clearMealReminderHistory() {
        UserDefaults.standard.removeObject(forKey: Self.MEAL_REMINDER_HISTORY_KEY)
    }
}
