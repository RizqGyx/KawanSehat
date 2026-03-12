import Foundation

// MARK: - HealthScoreService
/// Calculates composite health score based on nutrition, sleep, workout, and budget
class HealthScoreService {
    
    static let shared = HealthScoreService()
    private let storage = UserDefaultsService.shared
    
    // MARK: - Calculate Nutrition Score
    /// Score based on macro and calorie adherence (0-100)
    func nutritionScore(
        consumedCalories: Double,
        targetCalories: Double,
        consumedProtein: Double,
        targetProtein: Double,
        consumedCarbs: Double,
        targetCarbs: Double,
        consumedFat: Double,
        targetFat: Double
    ) -> Double {
        var score: Double = 0
        
        // Calorie adherence (40 points)
        let calorieAdherence = min(abs(consumedCalories / targetCalories), 1.0)
        let calorieDiff = abs(consumedCalories - targetCalories) / targetCalories
        let calorieScore = calorieAdherence > 0.5 ? min(40.0 * (1.0 - (calorieDiff * 0.5)), 40.0) : 0
        score += calorieScore
        
        // Protein adherence (20 points)
        let proteinAdherence = min(consumedProtein / targetProtein, 1.0)
        score += proteinAdherence * 20
        
        // Carbs adherence (20 points)
        let carbsAdherence = min(consumedCarbs / targetCarbs, 1.0)
        score += carbsAdherence * 20
        
        // Fat adherence (20 points)
        let fatAdherence = min(consumedFat / targetFat, 1.0)
        score += fatAdherence * 20
        
        return min(score, 100)
    }
    
    // MARK: - Calculate Sleep Score
    /// Score based on sleep hours (0-100)
    /// Target: 7-9 hours. Less or more = lower score
    func sleepScore(averageSleepHours: Double) -> Double {
        // Ideal range: 7-9 hours
        if averageSleepHours >= 7 && averageSleepHours <= 9 {
            return 100 // Perfect score
        } else if averageSleepHours >= 6.5 && averageSleepHours < 10 {
            return 80  // Good score
        } else if averageSleepHours >= 6 && averageSleepHours < 10.5 {
            return 60  // Fair score
        } else if averageSleepHours > 0 {
            return 40  // Poor score
        }
        return 0  // No sleep logged
    }
    
    // MARK: - Calculate Workout Score
    /// Score based on weekly workouts (0-100)
    /// Target: 5 workouts per week
    func workoutScore(weeklyWorkoutCount: Int, weeklyCaloriesBurned: Int) -> Double {
        let workoutPoints = min(Double(weeklyWorkoutCount) / 5.0 * 60, 60.0)
        let caloriePoints = min(Double(weeklyCaloriesBurned) / 2500.0 * 40, 40.0)
        return min(workoutPoints + caloriePoints, 100)
    }
    
    // MARK: - Calculate Budget Score
    /// Score based on sticking to budget (0-100)
    func budgetScore(spent: Double, budget: Double) -> Double {
        let usage = spent / budget
        
        // Perfect: stay within budget with good utilization (80-100%)
        if usage >= 0.8 && usage <= 1.0 {
            return 100
        }
        // Good: slightly under budget (70-79%)
        else if usage >= 0.7 && usage < 0.8 {
            return 85
        }
        // Fair: moderately under budget (50-69%)
        else if usage >= 0.5 && usage < 0.7 {
            return 70
        }
        // Poor: way under budget (<50%) - wasteful planning
        else if usage > 0 && usage < 0.5 {
            return 50
        }
        // Exceeded budget
        else if usage > 1.0 {
            let overage = min(usage - 1.0, 0.5) // Cap penalty at 50%
            return max(0, 50 - (overage * 100))
        }
        
        return 0
    }
    
    // MARK: - Calculate Composite Health Score
    /// Combines all scores with weights:
    /// - Nutrition: 30%
    /// - Sleep: 25%
    /// - Workout: 25%
    /// - Budget: 20%
    func compositeHealthScore(
        nutritionScore: Double,
        sleepScore: Double,
        workoutScore: Double,
        budgetScore: Double
    ) -> Int {
        let composite =
            (nutritionScore * 0.30) +
            (sleepScore * 0.25) +
            (workoutScore * 0.25) +
            (budgetScore * 0.20)
        
        return Int(min(composite, 100))
    }
}
