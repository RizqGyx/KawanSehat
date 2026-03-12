import Foundation
import SwiftUI
import Combine

// MARK: - WaterViewModel
/// ViewModel for water intake tracking
@MainActor
class WaterViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var logs: [WaterLog] = []
    @Published var todayTotal: Double = 0.0
    @Published var dailyGoal: Double = 2200  // in milliliters (2.2L by default)
    
    private let storage = UserDefaultsService.shared
    
    init(userProfile: UserProfile) {
        self.dailyGoal = userProfile.waterGoalL * 1000  // Convert from liters to ml
        loadLogs()
        updateTodayTotal()
    }
    
    // MARK: - Computed Properties
    var percentageComplete: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(todayTotal / dailyGoal, 1.0)
    }
    
    var todayTotalFormatted: String {
        return String(format: "%.1f L", todayTotal / 1000.0)
    }
    
    var remainingFormatted: String {
        let remaining = max(0, dailyGoal - todayTotal)
        return String(format: "%.1f L", remaining / 1000.0)
    }
    
    var motivationalMessage: String {
        let percentage = percentageComplete
        switch percentage {
        case 0..<0.25:
            return "Ayo mulai minum! Tubuhmu butuh hidrasi 💧"
        case 0.25..<0.5:
            return "Good start! Lanjutkan minum air 👍"
        case 0.5..<0.75:
            return "Separuh jalan! Terus semangat! 💪"
        case 0.75..<1.0:
            return "Hampir sampai target! Tinggal sedikit lagi! 🎯"
        default:
            return "Target tercapai! Luar biasa! 🎉"
        }
    }
    
    // MARK: - Load Logs
    private func loadLogs() {
        logs = storage.loadWaterLogs()
    }
    
    // MARK: - Update Today's Total
    private func updateTodayTotal() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        todayTotal = logs.filter { log in
            calendar.isDate(log.date, inSameDayAs: today)
        }.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Add Water
    func addWater(amount: Double) {
        let newLog = WaterLog(amount: amount)
        logs.insert(newLog, at: 0)
        storage.saveWaterLogs(logs)
        updateTodayTotal()
    }
    
    // MARK: - Remove Log
    func removeLog(_ log: WaterLog) {
        logs.removeAll { $0.id == log.id }
        storage.saveWaterLogs(logs)
        updateTodayTotal()
    }
    
    // MARK: - Get Today's Logs Only
    var todayLogs: [WaterLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return logs.filter { log in
            calendar.isDate(log.date, inSameDayAs: today)
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(_ profile: UserProfile) {
        self.dailyGoal = profile.waterGoalL * 1000  // Convert from liters to ml
    }
}
