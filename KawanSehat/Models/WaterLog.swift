import Foundation

// MARK: - Water Log Model
struct WaterLog: Identifiable, Codable {
    let id: UUID
    let amount: Double  // in milliliters
    let date: Date
    
    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.date = date
    }
    
    // MARK: - Computed Properties
    var amountInLiters: Double {
        return amount / 1000.0
    }
    
    var amountFormatted: String {
        if amount >= 1000 {
            return String(format: "%.1f L", amountInLiters)
        }
        return "\(Int(amount)) ml"
    }
    
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
