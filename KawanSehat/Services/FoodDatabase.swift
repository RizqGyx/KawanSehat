import Foundation

// MARK: - FoodDatabase Service
/// Hardcoded Indonesian food database for MVP.
/// In production, this would be fetched from a remote API or bundled SQLite.
class FoodDatabase {
    
    static let shared = FoodDatabase()
    private init() {}
    
    // MARK: - Full Food List
    lazy var allFoods: [FoodItem] = {
        return buildDatabase()
    }()
    
    // MARK: - Search
    func search(query: String) -> [FoodItem] {
        guard !query.isEmpty else { return allFoods }
        let q = query.lowercased()
        return allFoods.filter {
            $0.name.lowercased().contains(q) ||
            $0.nameEn.lowercased().contains(q) ||
            $0.tags.contains(where: { $0.lowercased().contains(q) })
        }
    }
    
    // MARK: - Suggestions Engine
    /// Find healthier AND cheaper alternatives for a given food item
    func suggestions(for food: FoodItem, budget: Double) -> [FoodSuggestion] {
        let candidates = allFoods.filter { candidate in
            // Exclude the food itself
            guard candidate.id != food.id else { return false }
            // Must be within budget
            guard candidate.priceIDR <= budget else { return false }
            // Healthier or equal health score
            guard candidate.healthScore >= food.healthScore else { return false }
            // Similar calorie range ±30%
            let calorieDiff = abs(candidate.calories - food.calories) / food.calories
            return calorieDiff <= 0.30
        }
        
        // Sort: cheapest + healthiest first
        let sorted = candidates.sorted {
            let scoreA = Double($0.healthScore) * 10 - $0.priceIDR / 1000
            let scoreB = Double($1.healthScore) * 10 - $1.priceIDR / 1000
            return scoreA > scoreB
        }
        
        return sorted.prefix(5).map { candidate in
            let savings = food.priceIDR - candidate.priceIDR
            let reason = buildReason(original: food, alternative: candidate)
            return FoodSuggestion(food: candidate, reason: reason, savingsIDR: max(0, savings))
        }
    }
    
    // MARK: - Budget-based daily meal plan
    func suggestMeals(calorieBudget: Double, priceBudget: Double) -> [FoodItem] {
        // Find foods that fit within budget and collectively approach calorie target
        let affordable = allFoods.filter { $0.priceIDR <= priceBudget / 3 }
        let healthy = affordable.filter { $0.healthScore >= 6 }.sorted { $0.healthScore > $1.healthScore }
        return Array(healthy.prefix(6))
    }
    
    // MARK: - Private Helpers
    private func buildReason(original: FoodItem, alternative: FoodItem) -> String {
        var reasons: [String] = []
        if alternative.healthScore > original.healthScore {
            reasons.append("lebih sehat")
        }
        if alternative.priceIDR < original.priceIDR {
            reasons.append("lebih murah")
        }
        if alternative.proteinG >= original.proteinG * 0.8 {
            reasons.append("protein setara")
        }
        if alternative.fiberG > original.fiberG {
            reasons.append("serat lebih tinggi")
        }
        return reasons.isEmpty ? "Alternatif serupa" : reasons.joined(separator: ", ").capitalized
    }
    
    // MARK: - Database Builder
    private func buildDatabase() -> [FoodItem] {
        return [
            // ============================================================
            // MAIN DISHES (Makanan Utama)
            // ============================================================
            FoodItem(name: "Nasi Goreng", nameEn: "Fried Rice", category: .mainDish,
                     servingSizeG: 300, priceIDR: 20000, calories: 450, proteinG: 12,
                     carbsG: 65, fatG: 14, fiberG: 2, healthScore: 5,
                     tags: ["nasi", "goreng", "rice", "populer"]),
            
            FoodItem(name: "Nasi Putih + Tempe + Sayur", nameEn: "Rice with Tempeh & Veggies", category: .mainDish,
                     servingSizeG: 350, priceIDR: 15000, calories: 420, proteinG: 18,
                     carbsG: 60, fatG: 8, fiberG: 6, healthScore: 8,
                     tags: ["nasi", "tempe", "sayur", "hemat"]),
            
            FoodItem(name: "Pecel Lele", nameEn: "Fried Catfish with Sambal", category: .mainDish,
                     servingSizeG: 300, priceIDR: 18000, calories: 480, proteinG: 28,
                     carbsG: 35, fatG: 22, fiberG: 3, healthScore: 6,
                     tags: ["lele", "ikan", "goreng", "sambal"]),
            
            FoodItem(name: "Gado-Gado", nameEn: "Indonesian Salad with Peanut Sauce", category: .mainDish,
                     servingSizeG: 350, priceIDR: 20000, calories: 380, proteinG: 16,
                     carbsG: 42, fatG: 18, fiberG: 8, healthScore: 8,
                     tags: ["sayur", "kacang", "sehat", "vegetarian"]),
            
            FoodItem(name: "Soto Ayam", nameEn: "Chicken Soup", category: .mainDish,
                     servingSizeG: 400, priceIDR: 20000, calories: 320, proteinG: 22,
                     carbsG: 30, fatG: 10, fiberG: 2, healthScore: 7,
                     tags: ["ayam", "soto", "kuah", "sup"]),
            
            FoodItem(name: "Bakso", nameEn: "Indonesian Meatball Soup", category: .mainDish,
                     servingSizeG: 400, priceIDR: 18000, calories: 380, proteinG: 18,
                     carbsG: 45, fatG: 12, fiberG: 1, healthScore: 5,
                     tags: ["bakso", "daging", "kuah", "mie"]),
            
            FoodItem(name: "Nasi Uduk", nameEn: "Coconut Milk Rice", category: .mainDish,
                     servingSizeG: 300, priceIDR: 18000, calories: 520, proteinG: 10,
                     carbsG: 70, fatG: 22, fiberG: 2, healthScore: 4,
                     tags: ["nasi", "santan", "jakarta"]),
            
            FoodItem(name: "Bubur Ayam", nameEn: "Chicken Congee", category: .mainDish,
                     servingSizeG: 400, priceIDR: 15000, calories: 280, proteinG: 14,
                     carbsG: 40, fatG: 8, fiberG: 1, healthScore: 7,
                     tags: ["bubur", "ayam", "sarapan", "ringan"]),
            
            FoodItem(name: "Nasi + Pepes Ikan", nameEn: "Rice with Steamed Fish in Banana Leaf", category: .mainDish,
                     servingSizeG: 350, priceIDR: 22000, calories: 390, proteinG: 26,
                     carbsG: 48, fatG: 9, fiberG: 3, healthScore: 9,
                     tags: ["ikan", "pepes", "sehat", "kukus"]),
            
            FoodItem(name: "Mie Goreng", nameEn: "Fried Noodles", category: .mainDish,
                     servingSizeG: 300, priceIDR: 18000, calories: 430, proteinG: 11,
                     carbsG: 62, fatG: 14, fiberG: 2, healthScore: 4,
                     tags: ["mie", "goreng", "noodles"]),
            
            FoodItem(name: "Nasi + Ayam Bakar", nameEn: "Rice with Grilled Chicken", category: .mainDish,
                     servingSizeG: 400, priceIDR: 28000, calories: 500, proteinG: 35,
                     carbsG: 52, fatG: 14, fiberG: 2, healthScore: 7,
                     tags: ["ayam", "bakar", "grilled", "protein"]),
            
            FoodItem(name: "Sayur Asem + Tempe + Nasi", nameEn: "Sour Vegetable Soup with Tempeh", category: .mainDish,
                     servingSizeG: 450, priceIDR: 15000, calories: 350, proteinG: 16,
                     carbsG: 55, fatG: 7, fiberG: 9, healthScore: 9,
                     tags: ["sayur", "asem", "tempe", "sehat", "hemat"]),
            
            // ============================================================
            // SIDE DISHES (Lauk Pauk)
            // ============================================================
            FoodItem(name: "Tempe Goreng", nameEn: "Fried Tempeh", category: .sideDish,
                     servingSizeG: 100, priceIDR: 3000, calories: 190, proteinG: 14,
                     carbsG: 12, fatG: 10, fiberG: 4, healthScore: 7,
                     tags: ["tempe", "goreng", "protein", "nabati"]),
            
            FoodItem(name: "Tempe Bacem", nameEn: "Sweet Braised Tempeh", category: .sideDish,
                     servingSizeG: 100, priceIDR: 4000, calories: 180, proteinG: 14,
                     carbsG: 15, fatG: 7, fiberG: 4, healthScore: 8,
                     tags: ["tempe", "bacem", "protein", "sehat"]),
            
            FoodItem(name: "Tahu Goreng", nameEn: "Fried Tofu", category: .sideDish,
                     servingSizeG: 100, priceIDR: 2000, calories: 130, proteinG: 10,
                     carbsG: 6, fatG: 8, fiberG: 1, healthScore: 6,
                     tags: ["tahu", "goreng", "protein", "murah"]),
            
            FoodItem(name: "Ayam Goreng", nameEn: "Fried Chicken", category: .sideDish,
                     servingSizeG: 150, priceIDR: 15000, calories: 320, proteinG: 28,
                     carbsG: 8, fatG: 20, fiberG: 0, healthScore: 5,
                     tags: ["ayam", "goreng", "protein"]),
            
            FoodItem(name: "Ikan Asin", nameEn: "Salted Fish", category: .sideDish,
                     servingSizeG: 50, priceIDR: 5000, calories: 110, proteinG: 20,
                     carbsG: 0, fatG: 3, fiberG: 0, healthScore: 5,
                     tags: ["ikan", "asin", "protein", "asin"]),
            
            FoodItem(name: "Telur Dadar", nameEn: "Omelette", category: .sideDish,
                     servingSizeG: 100, priceIDR: 5000, calories: 150, proteinG: 10,
                     carbsG: 2, fatG: 11, fiberG: 0, healthScore: 6,
                     tags: ["telur", "dadar", "protein", "murah"]),
            
            FoodItem(name: "Telur Rebus", nameEn: "Boiled Egg", category: .sideDish,
                     servingSizeG: 60, priceIDR: 3000, calories: 80, proteinG: 7,
                     carbsG: 1, fatG: 5, fiberG: 0, healthScore: 8,
                     tags: ["telur", "rebus", "protein", "sehat", "murah"]),
            
            // ============================================================
            // VEGETABLES (Sayuran)
            // ============================================================
            FoodItem(name: "Bayam Rebus", nameEn: "Boiled Spinach", category: .vegetable,
                     servingSizeG: 100, priceIDR: 3000, calories: 35, proteinG: 3,
                     carbsG: 5, fatG: 0.5, fiberG: 4, healthScore: 10,
                     tags: ["bayam", "sayur", "sehat", "hijau"]),
            
            FoodItem(name: "Kangkung Tumis", nameEn: "Stir-fried Water Spinach", category: .vegetable,
                     servingSizeG: 150, priceIDR: 8000, calories: 70, proteinG: 4,
                     carbsG: 8, fatG: 2, fiberG: 3, healthScore: 9,
                     tags: ["kangkung", "sayur", "tumis", "sehat"]),
            
            FoodItem(name: "Lalapan", nameEn: "Fresh Vegetables Side", category: .vegetable,
                     servingSizeG: 100, priceIDR: 2000, calories: 40, proteinG: 2,
                     carbsG: 8, fatG: 0, fiberG: 5, healthScore: 10,
                     tags: ["lalapan", "mentah", "segar", "murah", "sehat"]),
            
            // ============================================================
            // SNACKS (Camilan)
            // ============================================================
            FoodItem(name: "Pisang", nameEn: "Banana", category: .snack,
                     servingSizeG: 100, priceIDR: 2000, calories: 90, proteinG: 1,
                     carbsG: 23, fatG: 0.3, fiberG: 2.6, healthScore: 9,
                     tags: ["pisang", "buah", "snack", "murah", "sehat"]),
            
            FoodItem(name: "Roti Gandum", nameEn: "Whole Wheat Bread", category: .snack,
                     servingSizeG: 60, priceIDR: 5000, calories: 150, proteinG: 5,
                     carbsG: 28, fatG: 2, fiberG: 3, healthScore: 7,
                     tags: ["roti", "gandum", "sarapan", "sehat"]),
            
            FoodItem(name: "Keripik Singkong", nameEn: "Cassava Chips", category: .snack,
                     servingSizeG: 50, priceIDR: 5000, calories: 230, proteinG: 2,
                     carbsG: 32, fatG: 11, fiberG: 1, healthScore: 3,
                     tags: ["keripik", "singkong", "snack", "gorengan"]),
            
            FoodItem(name: "Kacang Rebus", nameEn: "Boiled Peanuts", category: .snack,
                     servingSizeG: 100, priceIDR: 5000, calories: 180, proteinG: 8,
                     carbsG: 12, fatG: 12, fiberG: 4, healthScore: 7,
                     tags: ["kacang", "rebus", "snack", "protein"]),
            
            // ============================================================
            // BEVERAGES (Minuman)
            // ============================================================
            FoodItem(name: "Es Teh Manis", nameEn: "Sweet Iced Tea", category: .beverage,
                     servingSizeG: 250, priceIDR: 5000, calories: 90, proteinG: 0,
                     carbsG: 23, fatG: 0, fiberG: 0, healthScore: 3,
                     tags: ["teh", "es", "manis", "minuman"]),
            
            FoodItem(name: "Air Putih", nameEn: "Water", category: .beverage,
                     servingSizeG: 250, priceIDR: 0, calories: 0, proteinG: 0,
                     carbsG: 0, fatG: 0, fiberG: 0, healthScore: 10,
                     tags: ["air", "putih", "sehat", "gratis"]),
            
            FoodItem(name: "Jus Jeruk", nameEn: "Orange Juice", category: .beverage,
                     servingSizeG: 200, priceIDR: 8000, calories: 80, proteinG: 1,
                     carbsG: 19, fatG: 0, fiberG: 1, healthScore: 7,
                     tags: ["jus", "jeruk", "vitamin", "buah"]),
            
            FoodItem(name: "Susu Sapi", nameEn: "Cow's Milk", category: .beverage,
                     servingSizeG: 250, priceIDR: 6000, calories: 150, proteinG: 8,
                     carbsG: 12, fatG: 8, fiberG: 0, healthScore: 7,
                     tags: ["susu", "sapi", "protein", "kalsium"]),
            
            // ============================================================
            // RICE & CARBS
            // ============================================================
            FoodItem(name: "Nasi Putih", nameEn: "White Rice", category: .rice,
                     servingSizeG: 200, priceIDR: 5000, calories: 260, proteinG: 5,
                     carbsG: 57, fatG: 0.5, fiberG: 0.5, healthScore: 5,
                     tags: ["nasi", "putih", "karbo"]),
            
            FoodItem(name: "Nasi Merah", nameEn: "Brown Rice", category: .rice,
                     servingSizeG: 200, priceIDR: 7000, calories: 220, proteinG: 5,
                     carbsG: 46, fatG: 1.5, fiberG: 3.5, healthScore: 8,
                     tags: ["nasi", "merah", "sehat", "serat"]),
            
            FoodItem(name: "Singkong Rebus", nameEn: "Boiled Cassava", category: .rice,
                     servingSizeG: 200, priceIDR: 5000, calories: 160, proteinG: 2,
                     carbsG: 38, fatG: 0.5, fiberG: 2, healthScore: 7,
                     tags: ["singkong", "rebus", "karbo", "murah", "sehat"]),
            
            FoodItem(name: "Ubi Jalar Rebus", nameEn: "Boiled Sweet Potato", category: .rice,
                     servingSizeG: 200, priceIDR: 5000, calories: 172, proteinG: 3,
                     carbsG: 40, fatG: 0.2, fiberG: 4, healthScore: 9,
                     tags: ["ubi", "jalar", "sehat", "serat", "murah"]),
        ]
    }
}
