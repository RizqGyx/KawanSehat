import Foundation

// MARK: - Sleep Quality
enum SleepQuality: String, CaseIterable, Codable {
    case poor = "Buruk"
    case fair = "Cukup"
    case good = "Baik"
    case excellent = "Sangat Baik"
    
    var rating: Int {
        switch self {
        case .poor: return 1
        case .fair: return 2
        case .good: return 3
        case .excellent: return 4
        }
    }
    
    var emoji: String {
        switch self {
        case .poor: return "😴"
        case .fair: return "😕"
        case .good: return "😊"
        case .excellent: return "😴✨"
        }
    }
}

// MARK: - Sleep Log Model
struct SleepLog: Identifiable, Codable {
    let id: UUID
    let durationHours: Double
    let quality: SleepQuality
    let note: String
    let date: Date
    
    init(
        id: UUID = UUID(),
        durationHours: Double,
        quality: SleepQuality,
        note: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.durationHours = durationHours
        self.quality = quality
        self.note = note
        self.date = date
    }
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var time: String {
        let hours = Int(durationHours)
        let minutes = Int((durationHours - Double(hours)) * 60)
        return "\(hours)j \(minutes)m"
    }
}
