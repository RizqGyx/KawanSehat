import Foundation

// MARK: - Quest Type
enum QuestType: String, CaseIterable, Codable {
    case drink2L = "Minum 2L Air"
    case eatThreeMeals = "Catat 3 Makanan"
    case workout30Min = "Olahraga 30 Menit"
    case sleep7Hours = "Tidur 7 Jam"
    case stayInBudget = "Tetap dalam Budget"
    
    var icon: String {
        switch self {
        case .drink2L: return "drop.fill"
        case .eatThreeMeals: return "fork.knife"
        case .workout30Min: return "dumbbell.fill"
        case .sleep7Hours: return "moon.stars.fill"
        case .stayInBudget: return "wallet.pass.fill"
        }
    }
    
    var description: String {
        rawValue
    }
    
    var reward: Int {  // XP reward
        switch self {
        case .drink2L: return 10
        case .eatThreeMeals: return 20
        case .workout30Min: return 30
        case .sleep7Hours: return 25
        case .stayInBudget: return 15
        }
    }
}

// MARK: - Quest Model
struct Quest: Identifiable, Codable {
    let id: UUID
    let type: QuestType
    let completed: Bool
    let completedDate: Date?
    let createdDate: Date
    
    init(
        id: UUID = UUID(),
        type: QuestType,
        completed: Bool = false,
        completedDate: Date? = nil,
        createdDate: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.completed = completed
        self.completedDate = completedDate
        self.createdDate = createdDate
    }
    
    var createdDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdDate)
    }
    
    var completedDateFormatted: String? {
        guard let date = completedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(createdDate)
    }
}
