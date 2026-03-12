import Foundation
import SwiftUI
import Combine

// MARK: - SleepViewModel
@MainActor
class SleepViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var sleepLogs: [SleepLog] = []
    @Published var geminiAdvice = ""
    @Published var isLoadingAdvice = false
    
    private let storage = UserDefaultsService.shared
    private let geminiService = GeminiService.shared
    
    init() {
        loadSleepLogs()
    }
    
    // MARK: - Add Sleep Log
    func addSleepLog(durationHours: Double, quality: SleepQuality, note: String = "") {
        let newLog = SleepLog(
            durationHours: durationHours,
            quality: quality,
            note: note
        )
        sleepLogs.insert(newLog, at: 0)
        saveSleepLogs()
        getGeminiAdvice()
    }
    
    // MARK: - Remove Sleep Log
    func removeSleepLog(_ log: SleepLog) {
        sleepLogs.removeAll { $0.id == log.id }
        saveSleepLogs()
        getGeminiAdvice()
    }
    
    // MARK: - Get Last 7 Days Sleep Logs
    var last7DaysSleep: [SleepLog] {
        let calendar = Calendar.current
        let last7Days = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return sleepLogs.filter { $0.date >= last7Days }.sorted { $0.date > $1.date }
    }
    
    // MARK: - Calculate Average Sleep
    var averageSleepHours: Double {
        guard !last7DaysSleep.isEmpty else { return 0 }
        let totalHours = last7DaysSleep.reduce(0) { $0 + $1.durationHours }
        return totalHours / Double(last7DaysSleep.count)
    }
    
    var averageSleepFormatted: String {
        let hours = Int(averageSleepHours)
        let minutes = Int((averageSleepHours - Double(hours)) * 60)
        return "\(hours)j \(minutes)m"
    }
    
    // MARK: - Calculate Average Quality Rating
    var averageQualityRating: Double {
        guard !last7DaysSleep.isEmpty else { return 0 }
        let totalRating = last7DaysSleep.reduce(0) { $0 + Double($1.quality.rating) }
        return totalRating / Double(last7DaysSleep.count)
    }
    
    // MARK: - Get Gemini Sleep Advice
    func getGeminiAdvice() {
        isLoadingAdvice = true
        
        let prompt = """
        User's average sleep in the last 7 days: \(averageSleepFormatted)
        Average sleep quality rating (1-4): \(String(format: "%.1f", averageQualityRating))
        
        Provide brief, actionable sleep improvement advice in Indonesian (max 100 words).
        Focus on practical tips based on their sleep patterns.
        """
        
        Task {
            do {
                let response = try await geminiService.generateText(prompt: prompt)
                self.geminiAdvice = response
            } catch {
                self.geminiAdvice = "Lanjutkan usaha untuk menjaga pola tidur yang konsisten. Target adalah 7-9 jam per malam."
            }
            self.isLoadingAdvice = false
        }
    }
    
    // MARK: - Persistence
    private func loadSleepLogs() {
        sleepLogs = storage.loadSleepLogs()
    }
    
    private func saveSleepLogs() {
        storage.saveSleepLogs(sleepLogs)
    }
}
