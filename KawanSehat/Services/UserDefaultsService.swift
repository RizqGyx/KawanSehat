import Foundation

// MARK: - UserDefaultsService
/// Handles persistence for user profile and reminders using UserDefaults.
/// For MVP this is sufficient; replace with CoreData or CloudKit for production.
class UserDefaultsService {
    
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let userProfile = "user_profile_v1"
        static let reminders = "health_reminders_v1"
        static let smartReminderConfig = "smart_reminder_config_v1"
        static let lastAppOpenDate = "last_app_open_date"
        static let suggestionHistory = "gemini_suggestion_history_v1"
        static let waterLogs = "water_logs_v1"
        static let mealLogs = "meal_logs_v1"
        static let expenses = "expenses_v1"
        static let sleepLogs = "sleep_logs_v1"
        static let workoutLogs = "workout_logs_v1"
        static let quests = "quests_v1"
    }
    
    // MARK: - UserProfile
    func saveProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            defaults.set(data, forKey: Keys.userProfile)
        }
    }
    
    func loadProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: Keys.userProfile),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }
    
    // MARK: - Reminders
    func saveReminders(_ reminders: [HealthReminder]) {
        if let data = try? JSONEncoder().encode(reminders) {
            defaults.set(data, forKey: Keys.reminders)
        }
    }
    
    func loadReminders() -> [HealthReminder] {
        guard let data = defaults.data(forKey: Keys.reminders),
              let reminders = try? JSONDecoder().decode([HealthReminder].self, from: data) else {
            return HealthGoalType.allCases.map { HealthReminder(goalType: $0) }
        }
        return reminders
    }
    
    // MARK: - Smart Reminder Config
    func saveSmartConfig(_ config: SmartReminderConfig) {
        if let data = try? JSONEncoder().encode(config) {
            defaults.set(data, forKey: Keys.smartReminderConfig)
        }
    }
    
    func loadSmartConfig() -> SmartReminderConfig {
        guard let data = defaults.data(forKey: Keys.smartReminderConfig),
              let config = try? JSONDecoder().decode(SmartReminderConfig.self, from: data) else {
            return SmartReminderConfig()
        }
        return config
    }
    
    // MARK: - App Open Tracking
    func recordAppOpen() {
        defaults.set(Date(), forKey: Keys.lastAppOpenDate)
    }
    
    func hoursSinceLastOpen() -> Int {
        guard let lastOpen = defaults.object(forKey: Keys.lastAppOpenDate) as? Date else {
            return 0
        }
        let elapsed = Date().timeIntervalSince(lastOpen)
        return Int(elapsed / 3600)
    }
    
    // MARK: - Gemini Suggestion History
    func saveSuggestionHistory(_ suggestions: [GeminiSuggestion]) {
        if let data = try? JSONEncoder().encode(suggestions) {
            defaults.set(data, forKey: Keys.suggestionHistory)
        }
    }
    
    func loadSuggestionHistory() -> [GeminiSuggestion] {
        guard let data = defaults.data(forKey: Keys.suggestionHistory),
              let suggestions = try? JSONDecoder().decode([GeminiSuggestion].self, from: data) else {
            return []
        }
        return suggestions
    }
    
    // MARK: - Water Logs
    func saveWaterLogs(_ logs: [WaterLog]) {
        if let data = try? JSONEncoder().encode(logs) {
            defaults.set(data, forKey: Keys.waterLogs)
        }
    }
    
    func loadWaterLogs() -> [WaterLog] {
        guard let data = defaults.data(forKey: Keys.waterLogs),
              let logs = try? JSONDecoder().decode([WaterLog].self, from: data) else {
            return []
        }
        return logs
    }
    
    // MARK: - Meal Logs
    func saveMealLogs(_ logs: [MealLog]) {
        if let data = try? JSONEncoder().encode(logs) {
            defaults.set(data, forKey: Keys.mealLogs)
        }
    }
    
    func loadMealLogs() -> [MealLog] {
        guard let data = defaults.data(forKey: Keys.mealLogs),
              let logs = try? JSONDecoder().decode([MealLog].self, from: data) else {
            return []
        }
        return logs
    }
    
    // MARK: - Expenses
    func saveExpenses(_ expenses: [Expense]) {
        if let data = try? JSONEncoder().encode(expenses) {
            defaults.set(data, forKey: Keys.expenses)
        }
    }
    
    func loadExpenses() -> [Expense] {
        guard let data = defaults.data(forKey: Keys.expenses),
              let expenses = try? JSONDecoder().decode([Expense].self, from: data) else {
            return []
        }
        return expenses
    }
    
    // MARK: - Sleep Logs
    func saveSleepLogs(_ logs: [SleepLog]) {
        if let data = try? JSONEncoder().encode(logs) {
            defaults.set(data, forKey: Keys.sleepLogs)
        }
    }
    
    func loadSleepLogs() -> [SleepLog] {
        guard let data = defaults.data(forKey: Keys.sleepLogs),
              let logs = try? JSONDecoder().decode([SleepLog].self, from: data) else {
            return []
        }
        return logs
    }
    
    // MARK: - Workout Logs
    func saveWorkoutLogs(_ logs: [WorkoutLog]) {
        if let data = try? JSONEncoder().encode(logs) {
            defaults.set(data, forKey: Keys.workoutLogs)
        }
    }
    
    func loadWorkoutLogs() -> [WorkoutLog] {
        guard let data = defaults.data(forKey: Keys.workoutLogs),
              let logs = try? JSONDecoder().decode([WorkoutLog].self, from: data) else {
            return []
        }
        return logs
    }
    
    // MARK: - Quests
    func saveQuests(_ quests: [Quest]) {
        if let data = try? JSONEncoder().encode(quests) {
            defaults.set(data, forKey: Keys.quests)
        }
    }
    
    func loadQuests() -> [Quest] {
        guard let data = defaults.data(forKey: Keys.quests),
              let quests = try? JSONDecoder().decode([Quest].self, from: data) else {
            return []
        }
        return quests
    }
}
