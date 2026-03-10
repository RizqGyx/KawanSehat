import Foundation
import UserNotifications

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
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "HealthBudget"
        content.body = reminder.goalType.defaultMessage
        content.sound = .default
        content.badge = 1
        
        // Schedule for each selected day of week
        for day in reminder.daysOfWeek {
            var dateComponents = DateComponents()
            dateComponents.hour = reminder.hour
            dateComponents.minute = reminder.minute
            dateComponents.weekday = day  // 1=Sunday, 7=Saturday
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = "\(reminder.goalType.notificationPrefix)_day\(day)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error { print("Schedule error: \(error)") }
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
        let config = storage.loadSmartConfig()
        guard config.isEnabled else { return }
        
        let thresholdSeconds = Double(config.inactiveHoursThreshold) * 3600
        
        let content = UNMutableNotificationContent()
        content.title = "HealthBudget 💚"
        content.body = motivationalMessages.randomElement()?.replacingOccurrences(
            of: "\(0)", with: "\(config.inactiveHoursThreshold)"
        ) ?? "Yuk kembali ke HealthBudget!"
        content.sound = .default
        
        // Fire after threshold hours from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: thresholdSeconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "smart_reminder_reengagement",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error { print("Smart reminder error: \(error)") }
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
}
