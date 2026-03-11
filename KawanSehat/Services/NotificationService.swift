import Foundation
import UIKit
import UserNotifications
import Combine

// MARK: - NotificationService
/// Manages all local push notifications: scheduled reminders + smart re-engagement.
@MainActor
class NotificationService: ObservableObject {
    
    @Published var isAuthorized: Bool = false
    
    private let center = UNUserNotificationCenter.current()
    private let storage = UserDefaultsService.shared
    
    // MARK: - Smart re-engagement motivational messages
    private let motivationalMessages = [
        "Hei! Sudah \(0) jam kamu tidak membuka HealthBudget 👋\nYuk catat makananmu hari ini!",
        "Jangan lupa kesehatanmu! Buka app dan catat progress-mu 💪",
        "Konsistensi adalah kunci! Yuk buka HealthBudget sebentar 🌟",
        "Tubuhmu butuh perhatianmu. Cek rekomendasi makanan hari ini! 🥗",
        "Setiap langkah kecil berarti. Ayo kembali ke track! 🏃"
    ]
    
    // MARK: - Authorization
    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
        } catch {
            print("Notification permission error: \(error)")
            isAuthorized = false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Record App Open
    /// Call this every time app becomes active to reset smart reminder timer
    func recordAppOpen() {
        storage.recordAppOpen()
        // Cancel any pending smart reminders since user is now in app
        cancelSmartReminder()
        // Schedule next smart reminder check
        scheduleSmartReminderIfNeeded()
    }
    
    // MARK: - Schedule Scheduled Reminders
    func scheduleReminder(_ reminder: HealthReminder) {
        guard reminder.isEnabled else {
            cancelReminder(for: reminder.goalType)
            return
        }
        
        // Ensure user has granted permission before scheduling
        guard isAuthorized else {
            print("⚠️ Notification not authorized - cannot schedule reminder for \(reminder.goalType.rawValue)")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "KawanSehat"
        content.body = reminder.goalType.defaultMessage
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        // Schedule for each selected day of week
        for day in reminder.daysOfWeek {
            var dateComponents = DateComponents()
            dateComponents.hour = reminder.hour
            dateComponents.minute = reminder.minute
            dateComponents.weekday = day  // 1=Sunday, 7=Saturday
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = "\(reminder.goalType.notificationPrefix)_day\(day)_\(UUID().uuidString)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            let notificationCenter = self.center
            notificationCenter.add(request) { error in
                if let error {
                    print("❌ Schedule error for \(reminder.goalType.rawValue): \(error.localizedDescription)")
                } else {
                    print("✅ Successfully scheduled notification: \(identifier)")
                }
            }
        }
    }
    
    func cancelReminder(for goalType: HealthGoalType) {
        // Cancel all notifications with matching prefix
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix(goalType.notificationPrefix) }
                .map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
    
    // MARK: - Smart Re-engagement Reminder
    /// Schedules a one-time notification if user hasn't opened the app for X hours
    func scheduleSmartReminderIfNeeded() {
        // Ensure we have permission
        guard isAuthorized else {
            print("⚠️ Notification not authorized - cannot schedule smart reminder")
            return
        }
        
        let config = storage.loadSmartConfig()
        guard config.isEnabled else { return }
        
        let thresholdSeconds = Double(config.inactiveHoursThreshold) * 3600
        
        let content = UNMutableNotificationContent()
        content.title = "KawanSehat 💚"
        content.body = motivationalMessages.randomElement()?.replacingOccurrences(
            of: "\(0)", with: "\(config.inactiveHoursThreshold)"
        ) ?? "Yuk kembali ke KawanSehat!"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        // Cancel previous smart reminder before adding a new one
        center.removePendingNotificationRequests(withIdentifiers: ["smart_reminder_reengagement"])
        
        // Fire after threshold hours from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: thresholdSeconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "smart_reminder_reengagement",
            content: content,
            trigger: trigger
        )
        
        let notificationCenter = self.center
        notificationCenter.add(request) { error in
            if let error {
                print("❌ Smart reminder error: \(error.localizedDescription)")
            } else {
                print("✅ Smart reminder scheduled to trigger in \(config.inactiveHoursThreshold) hours")
            }
        }
    }
    
    func cancelSmartReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["smart_reminder_reengagement"])
    }
    
    // MARK: - Batch update all reminders
    func updateAllReminders(_ reminders: [HealthReminder]) {
        // Clear all existing scheduled reminders
        let allPrefixes = HealthGoalType.allCases.map { $0.notificationPrefix }
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { req in allPrefixes.contains(where: { req.identifier.hasPrefix($0) }) }
                .map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
        
        // Re-schedule enabled ones
        for reminder in reminders where reminder.isEnabled {
            scheduleReminder(reminder)
        }
    }
    
    // MARK: - Smart Meal Reminders (Breakfast, Lunch, Dinner)
    /// Schedule 3 daily smart meal reminders with Gemini recommendations
    func scheduleMealReminders(userProfile: UserProfile) {
        guard isAuthorized else {
            print("⚠️ Notification not authorized - cannot schedule meal reminders")
            return
        }
        
        // Cancel existing meal reminders first
        cancelMealReminders()
        
        // Schedule breakfast at 7:00 AM
        scheduleMealReminder(
            mealType: .breakfast,
            hour: 7,
            minute: 0,
            userProfile: userProfile
        )
        
        // Schedule lunch at 12:00 PM
        scheduleMealReminder(
            mealType: .lunch,
            hour: 15,
            minute: 55,
            userProfile: userProfile
        )
        
        // Schedule dinner at 6:00 PM
        scheduleMealReminder(
            mealType: .dinner,
            hour: 18,
            minute: 0,
            userProfile: userProfile
        )
    }
    
    /// Schedule a single meal reminder with generated recommendation
    private func scheduleMealReminder(
        mealType: MealRecommendation.MealType,
        hour: Int,
        minute: Int,
        userProfile: UserProfile
    ) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create content with meal recommendation
        let content = UNMutableNotificationContent()
        content.title = "KawanSehat - \(mealType.rawValue) 🍽️"
        
        // Use a default message while waiting for Gemini to generate recommendation
        content.body = "Waktunya \(mealType.rawValue.lowercased())! Buka app untuk rekomendasi makanan sehat dan terjangkau untuk kamu."
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        // Add user info for custom actions
        content.userInfo = [
            "mealType": mealType.rawValue,
            "userName": userProfile.name,
            "caloriePerMeal": userProfile.caloriesPerMealIntake,
            "budgetPerMeal": userProfile.budgetPerMealIDR
        ]
        
        let identifier = "meal_reminder_\(mealType.rawValue.lowercased())_daily"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        let notificationCenter = self.center
        notificationCenter.add(request) { error in
            if let error {
                print("❌ Meal reminder error for \(mealType.rawValue): \(error.localizedDescription)")
            } else {
                print("✅ Successfully scheduled \(mealType.rawValue) reminder for \(String(format: "%02d:%02d", hour, minute))")
            }
        }
    }
    
    /// Cancel all meal reminders
    func cancelMealReminders() {
        let mealTypes = ["breakfast", "lunch", "dinner"]
        let identifiers = mealTypes.map { "meal_reminder_\($0)_daily" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("✅ Cancelled all meal reminders")
    }
    
    /// Generate and send smart meal notification with Gemini recommendation
    func sendSmartMealNotification(
        mealType: MealRecommendation.MealType,
        recommendation: MealRecommendation,
        userProfile: UserProfile
    ) async {
        guard isAuthorized else {
            print("⚠️ Notification not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "✨ \(mealType.rawValue) untuk \(recommendation.foodName)"
        content.body = """
        \(recommendation.description)
        
        Kalori: \(recommendation.calorieInfo)
        Budget: \(recommendation.budgetInfo)
        """
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.userInfo = [
            "mealType": mealType.rawValue,
            "foodName": recommendation.foodName
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "smart_meal_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { [storage, mealType, recommendation, userProfile] error in
            if let error {
                print("❌ Smart meal notification error: \(error.localizedDescription)")
            } else {
                print("✅ Smart meal notification sent for \(mealType.rawValue)")
                // Save to history
                let historyItem = MealReminderHistoryItem(
                    mealType: mealType,
                    recommendation: recommendation,
                    userProfile: userProfile
                )
                storage.addMealReminderHistoryItem(historyItem)
            }
        }
    }
    
    /// Generate recommendations for all upcoming meals (for display in notifications)
    func generateUpcomingMealRecommendations(
        userProfile: UserProfile,
        geminiService: GeminiService
    ) async {
        guard isAuthorized else {
            print("⚠️ Cannot generate meal recommendations - notification not authorized")
            return
        }
        
        let mealTypes: [MealRecommendation.MealType] = [.breakfast, .lunch, .dinner]
        
        for mealType in mealTypes {
            do {
                if let recommendation = await geminiService.generateMealRecommendation(
                    mealType: mealType,
                    userProfile: userProfile
                ) {
                    print("✅ Generated \(mealType.rawValue) recommendation: \(recommendation.foodName)")
                    // Save to history
                    let historyItem = MealReminderHistoryItem(
                        mealType: mealType,
                        recommendation: recommendation,
                        userProfile: userProfile
                    )
                    storage.addMealReminderHistoryItem(historyItem)
                }
            }
        }
    }
}

