import Foundation

// MARK: - Expense Category
enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Makanan"
    case medicine = "Obat"
    case supplement = "Suplemen"
    case fitness = "Fitness"
    case other = "Lainnya"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .medicine: return "pills.fill"
        case .supplement: return "capsule.fill"
        case .fitness: return "dumbbell.fill"
        case .other: return "tag.fill"
        }
    }
    
    var color: String {
        switch self {
        case .food: return "orange"
        case .medicine: return "red"
        case .supplement: return "purple"
        case .fitness: return "green"
        case .other: return "gray"
        }
    }
}

// MARK: - Expense Model
struct Expense: Identifiable, Codable {
    let id: UUID
    let category: ExpenseCategory
    let amount: Double
    let note: String
    let date: Date
    
    init(
        id: UUID = UUID(),
        category: ExpenseCategory,
        amount: Double,
        note: String,
        date: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.amount = amount
        self.note = note
        self.date = date
    }
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var amountFormatted: String {
        return "Rp\(Int(amount))"
    }
}
