import Foundation
import SwiftUI
import Combine

// MARK: - ReminderViewModel
/// ViewModel for Feature 2: Smart Reminder Settings
@MainActor
class ReminderViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var reminders: [HealthReminder] = []
    @Published var smartConfig: SmartReminderConfig = SmartReminderConfig()
    @Published var isNotificationAuthorized: Bool = false
    @Published var showPermissionAlert: Bool = false
    
    private let storage = UserDefaultsService.shared
    private let notificationService: NotificationService
    
    init(notificationService: NotificationService) {
        self.notificationService = notificationService
        loadData()
    }
    
    // MARK: - Load saved data
    private func loadData() {
        reminders = storage.loadReminders()
        smartConfig = storage.loadSmartConfig()
    }
    
    // MARK: - Toggle a reminder on/off
    func toggleReminder(at index: Int) {
        guard index < reminders.count else { return }
        
        // If trying to enable and not authorized, request permission first
        if !reminders[index].isEnabled && !isNotificationAuthorized {
            showPermissionAlert = true
            return
        }
        
        reminders[index].isEnabled.toggle()
        
        // If enabled, also sync with notification service
        if reminders[index].isEnabled {
            saveAndSync()
        } else {
            saveAndSync()
        }
    }
    
    // MARK: - Update reminder time
    func updateTime(for index: Int, hour: Int, minute: Int) {
        guard index < reminders.count else { return }
        reminders[index].hour = hour
        reminders[index].minute = minute
        saveAndSync()
    }
    
    // MARK: - Update smart reminder threshold
    func updateSmartThreshold(_ hours: Int) {
        smartConfig.inactiveHoursThreshold = hours
        storage.saveSmartConfig(smartConfig)
        // Reschedule smart reminder with new threshold
        notificationService.cancelSmartReminder()
        if smartConfig.isEnabled {
            notificationService.scheduleSmartReminderIfNeeded()
        }
    }
    
    // MARK: - Toggle smart reminder
    func toggleSmartReminder() {
        smartConfig.isEnabled.toggle()
        storage.saveSmartConfig(smartConfig)
        if smartConfig.isEnabled {
            notificationService.scheduleSmartReminderIfNeeded()
        } else {
            notificationService.cancelSmartReminder()
        }
    }
    
    // MARK: - Request notification permission
    func requestPermission() async {
        await notificationService.requestPermission()
        isNotificationAuthorized = notificationService.isAuthorized
    }
    
    // MARK: - Save and sync with notification center
    private func saveAndSync() {
        storage.saveReminders(reminders)
        notificationService.updateAllReminders(reminders)
    }
    
    // MARK: - Check hours since last open (for display)
    var hoursSinceLastOpen: Int {
        return storage.hoursSinceLastOpen()
    }
    
    var lastOpenLabel: String {
        let hours = hoursSinceLastOpen
        if hours == 0 { return "Baru saja dibuka" }
        if hours < 24 { return "\(hours) jam yang lalu" }
        return "\(hours / 24) hari yang lalu"
    }
    
    // MARK: - Reminder time as Date (for DatePicker binding)
    func reminderTime(at index: Int) -> Date {
        guard index < reminders.count else { return Date() }
        var components = DateComponents()
        components.hour = reminders[index].hour
        components.minute = reminders[index].minute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func setReminderTime(at index: Int, from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        updateTime(for: index, hour: components.hour ?? 8, minute: components.minute ?? 0)
    }
}
