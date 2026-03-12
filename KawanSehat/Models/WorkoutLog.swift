import Foundation

// MARK: - Workout Log Model
struct WorkoutLog: Identifiable, Codable {
    let id: UUID
    let exerciseName: String
    let durationMinutes: Int
    let caloriesBurned: Int
    let intensity: String  // "Ringan", "Sedang", "Berat"
    let note: String
    let date: Date
    
    init(
        id: UUID = UUID(),
        exerciseName: String,
        durationMinutes: Int,
        caloriesBurned: Int,
        intensity: String,
        note: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.intensity = intensity
        self.note = note
        self.date = date
    }
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var intensityEmoji: String {
        switch intensity {
        case "Ringan": return "🟢"
        case "Sedang": return "🟡"
        case "Berat": return "🔴"
        default: return "⚪"
        }
    }
}
