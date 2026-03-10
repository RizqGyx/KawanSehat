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
}
