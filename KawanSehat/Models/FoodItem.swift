import Foundation

// MARK: - Food Category
enum FoodCategory: String, Codable, CaseIterable {
    case mainDish     = "Makanan Utama"
    case sideDish     = "Lauk Pauk"
    case vegetable    = "Sayuran"
    case snack        = "Camilan"
    case beverage     = "Minuman"
    case rice         = "Nasi & Karbohidrat"
}

// MARK: - FoodItem Model
struct FoodItem: Identifiable, Codable {
    let id: UUID
    let name: String                  // Indonesian food name
    let nameEn: String                // English name
    let category: FoodCategory
    let servingSizeG: Double          // Serving size in grams
    let priceIDR: Double              // Estimated price in Rupiah
    
    // Macronutrients per serving
    let calories: Double              // kcal
    let proteinG: Double              // grams
    let carbsG: Double                // grams
    let fatG: Double                  // grams
    let fiberG: Double                // grams
    
    // Health score 1-10 (higher = healthier)
    let healthScore: Int
    
    // Tags for matching alternatives
    let tags: [String]
    
    init(
        id: UUID = UUID(),
        name: String,
        nameEn: String = "",
        category: FoodCategory,
        servingSizeG: Double,
        priceIDR: Double,
        calories: Double,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        fiberG: Double = 0,
        healthScore: Int,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.category = category
        self.servingSizeG = servingSizeG
        self.priceIDR = priceIDR
        self.calories = calories
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.fiberG = fiberG
        self.healthScore = healthScore
        self.tags = tags
    }
    
    // MARK: - Computed Properties
    var priceFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.currencySymbol = "Rp"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: priceIDR)) ?? "Rp\(Int(priceIDR))"
    }
    
    var macroSummary: String {
        return "P: \(String(format: "%.1f", proteinG))g · K: \(String(format: "%.1f", carbsG))g · L: \(String(format: "%.1f", fatG))g"
    }
    
    var healthScoreLabel: String {
        switch healthScore {
        case 8...10: return "Sangat Sehat 🥗"
        case 6...7:  return "Cukup Sehat 👍"
        case 4...5:  return "Biasa Saja 😐"
        default:     return "Kurang Sehat ⚠️"
        }
    }
}

// MARK: - FoodSuggestion (wraps a food item with reason)
struct FoodSuggestion: Identifiable {
    let id = UUID()
    let food: FoodItem
    let reason: String          // Why this is suggested
    let savingsIDR: Double      // How much cheaper vs original
    
    var savingsFormatted: String {
        if savingsIDR > 0 {
            return "Hemat Rp\(Int(savingsIDR))"
        }
        return "Harga sama"
    }
}
