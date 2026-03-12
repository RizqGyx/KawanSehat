import Foundation

// MARK: - Meal Log Model
struct MealLog: Identifiable, Codable {
    let id: UUID
    let foodName: String
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
    let calories: Double
    let priceIDR: Double
    let date: Date
    
    init(
        id: UUID = UUID(),
        foodName: String,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        calories: Double,
        priceIDR: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.foodName = foodName
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.calories = calories
        self.priceIDR = priceIDR
        self.date = date
    }
    
    // MARK: - Computed Properties
    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var dateDayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var priceFormatted: String {
        return "Rp\(Int(priceIDR)):,".replacingOccurrences(of: ",,", with: ",")
    }
}
