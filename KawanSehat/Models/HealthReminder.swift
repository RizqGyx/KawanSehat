import Foundation

// MARK: - Health Goal Type
enum HealthGoalType: String, CaseIterable, Codable {
    case logMeals     = "Catat Makanan"
    case drinkWater   = "Minum Air"
    case exercise     = "Olahraga"
    case sleepEarly   = "Tidur Tepat Waktu"
    case checkWeight  = "Cek Berat Badan"
    
    var icon: String {
        switch self {
        case .logMeals:    return "fork.knife"
        case .drinkWater:  return "drop.fill"
        case .exercise:    return "figure.run"
        case .sleepEarly:  return "moon.fill"
        case .checkWeight: return "scalemass.fill"
        }
    }
    
    var defaultMessage: String {
        switch self {
        case .logMeals:    return "Waktunya catat makananmu hari ini! 🍽️"
        case .drinkWater:  return "Sudah minum air putih belum? 💧"
        case .exercise:    return "Jangan lupa olahraga hari ini! 💪"
        case .sleepEarly:  return "Waktunya istirahat, jaga kesehatanmu! 🌙"
        case .checkWeight: return "Yuk cek berat badanmu hari ini! ⚖️"
        }
    }
    
    /// Identifier prefix for notification
    var notificationPrefix: String {
        return "com.healthbudget.\(self.rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))"
    }
}

// MARK: - Reminder Model
struct HealthReminder: Identifiable, Codable {
    var id: UUID = UUID()
    var goalType: HealthGoalType
    var isEnabled: Bool = false
    var hour: Int = 8           // 24-hour format
    var minute: Int = 0
    var daysOfWeek: [Int] = [1,2,3,4,5,6,7]  // 1=Sunday ... 7=Saturday
    
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "\(hour):\(String(format: "%02d", minute))"
    }
    
    var daysLabel: String {
        if daysOfWeek.count == 7 { return "Setiap hari" }
        let names = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
        let sorted = daysOfWeek.sorted()
        return sorted.map { names[($0 - 1) % 7] }.joined(separator: ", ")
    }
}

// MARK: - Smart Reminder Trigger
struct SmartReminderConfig: Codable {
    var isEnabled: Bool = true
    var inactiveHoursThreshold: Int = 24  // Trigger if user hasn't opened app for X hours
    
    var thresholdLabel: String {
        return "Ingatkan jika tidak buka app \(inactiveHoursThreshold) jam"
    }
}
