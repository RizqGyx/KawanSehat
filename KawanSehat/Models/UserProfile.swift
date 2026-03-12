import Foundation

// MARK: - Activity Level Enum
enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary     = "Sedentary"         // Little to no exercise
    case light         = "Lightly Active"    // 1-3 days/week
    case moderate      = "Moderately Active" // 3-5 days/week
    case active        = "Very Active"       // 6-7 days/week
    case veryActive    = "Extra Active"      // Physical job or 2x/day
    
    /// Harris-Benedict activity multiplier
    var multiplier: Double {
        switch self {
        case .sedentary:   return 1.2
        case .light:       return 1.375
        case .moderate:    return 1.55
        case .active:      return 1.725
        case .veryActive:  return 1.9
        }
    }
    
    var description: String {
        switch self {
        case .sedentary:   return "Jarang olahraga"
        case .light:       return "Olahraga ringan 1-3x/minggu"
        case .moderate:    return "Olahraga sedang 3-5x/minggu"
        case .active:      return "Olahraga berat 6-7x/minggu"
        case .veryActive:  return "Atlet / kerja fisik berat"
        }
    }
}

// MARK: - Gender Enum
enum Gender: String, CaseIterable, Codable {
    case male   = "Laki-laki"
    case female = "Perempuan"
}

// MARK: - Dietary Preference Enum
enum DietaryPreference: String, CaseIterable, Codable {
    case regular     = "Regular"
    case vegetarian  = "Vegetarian"
    case halal       = "Halal"
}

// MARK: - UserProfile Model
struct UserProfile: Codable {
    var name: String = ""
    var age: Int = 25
    var gender: Gender = .male
    var weightKg: Double = 65.0
    var heightCm: Double = 165.0
    var activityLevel: ActivityLevel = .moderate
    var dailyBudgetIDR: Double = 50000  // in Indonesian Rupiah
    var monthlyBudgetIDR: Double = 1500000  // monthly health budget
    var dietaryPreference: DietaryPreference = .regular
    var hasCompletedOnboarding: Bool = false
    
    // Cached calculated values (set during onboarding)
    var cachedTDEE: Double = 2000  // Cached TDEE for dashboard display
    var cachedBMR: Double = 1200   // Cached BMR
    var proteinTargetG: Double = 150  // Daily protein target
    var carbsTargetG: Double = 200    // Daily carbs target
    var fatTargetG: Double = 65       // Daily fat target
    var waterGoalL: Double = 2.2      // Daily water intake goal in liters
    
    // MARK: - BMI Calculation
    /// BMI = weight(kg) / height(m)²
    var bmi: Double {
        let heightM = heightCm / 100.0
        return weightKg / (heightM * heightM)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Kurus (Underweight)"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Gemuk (Overweight)"
        default: return "Obesitas"
        }
    }
    
    var bmiColor: String {
        switch bmi {
        case ..<18.5: return "blue"
        case 18.5..<25: return "green"
        case 25..<30: return "orange"
        default: return "red"
        }
    }
    
    // MARK: - Water Goal (weight × 33 = ml, converted to liters)
    var calculatedWaterGoalL: Double {
        return (weightKg * 33.0) / 1000.0
    }
    
    var waterGoalFormatted: String {
        return String(format: "%.1f L", waterGoalL)
    }
    
    // MARK: - Harris-Benedict BMR Formula
    /// Calculates Basal Metabolic Rate (calories at rest)
    var bmr: Double {
        switch gender {
        case .male:
            // Male: 88.362 + (13.397 × weight kg) + (4.799 × height cm) − (5.677 × age)
            return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * Double(age))
        case .female:
            // Female: 447.593 + (9.247 × weight kg) + (3.098 × height cm) − (4.330 × age)
            return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * Double(age))
        }
    }
    
    /// Total Daily Energy Expenditure = BMR × activity multiplier
    var tdee: Double {
        return bmr * activityLevel.multiplier
    }
    
    /// Formatted daily calorie needs
    var dailyCaloriesFormatted: String {
        return String(format: "%.0f kal", tdee)
    }
    
    /// Calories per meal (assuming 3 meals a day)
    var caloriesPerMealIntake: Double {
        return tdee / 3.0
    }
    
    /// Formatted calories per meal
    var caloriesPerMealFormatted: String {
        return String(format: "%.0f kal", caloriesPerMealIntake)
    }
    
    /// Budget per meal (assuming 3 meals a day)
    var budgetPerMealIDR: Double {
        return dailyBudgetIDR / 3.0
    }
    
    /// Formatted budget per meal
    var budgetPerMealFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: budgetPerMealIDR)) ?? "Rp \(Int(budgetPerMealIDR))"
    }
}
