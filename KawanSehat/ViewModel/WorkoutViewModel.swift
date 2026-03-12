import Foundation
import SwiftUI
import Combine

// MARK: - WorkoutViewModel
@MainActor
class WorkoutViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var workoutLogs: [WorkoutLog] = []
    
    private let storage = UserDefaultsService.shared
    
    init() {
        loadWorkoutLogs()
    }
    
    // MARK: - Add Workout Log
    func addWorkout(
        exerciseName: String,
        durationMinutes: Int,
        caloriesBurned: Int,
        intensity: String,
        note: String = ""
    ) {
        let newLog = WorkoutLog(
            exerciseName: exerciseName,
            durationMinutes: durationMinutes,
            caloriesBurned: caloriesBurned,
            intensity: intensity,
            note: note
        )
        workoutLogs.insert(newLog, at: 0)
        saveWorkoutLogs()
    }
    
    // MARK: - Remove Workout Log
    func removeWorkout(_ log: WorkoutLog) {
        workoutLogs.removeAll { $0.id == log.id }
        saveWorkoutLogs()
    }
    
    // MARK: - Get Today's Workouts
    var todayWorkouts: [WorkoutLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return workoutLogs.filter { log in
            calendar.isDate(log.date, inSameDayAs: today)
        }
    }
    
    // MARK: - Check if user has logged workout today
    var hasWorkoutToday: Bool {
        !todayWorkouts.isEmpty
    }
    
    // MARK: - Calculate Today's Total Calories Burned
    var todayCaloriesBurned: Int {
        todayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    // MARK: - Calculate This Week's Workouts
    var thisWeekWorkouts: [WorkoutLog] {
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return workoutLogs.filter { $0.date >= lastWeek }.sorted { $0.date > $1.date }
    }
    
    var thisWeekCount: Int {
        thisWeekWorkouts.count
    }
    
    var thisWeekCaloriesBurned: Int {
        thisWeekWorkouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    // MARK: - Common exercises with estimated calories
    static let commonExercises: [String] = [
        "Berlari", "Berjalan", "Bersepeda", "Berenang",
        "Yoga", "Push-up", "Sit-up", "Plank",
        "Gym", "Zumba", "Sepak Bola", "Badminton",
        "Tenis", "Basket", "Hiking", "Menari"
    ]
    
    class Olahraga {
        static let estimatedCalories: [String: Int] = [
            "Berlari": 600,
            "Berjalan": 200,
            "Bersepeda": 400,
            "Berenang": 500,
            "Yoga": 200,
            "Push-up": 300,
            "Sit-up": 250,
            "Plank": 150,
            "Gym": 400,
            "Zumba": 500,
            "Sepak Bola": 500,
            "Badminton": 350,
            "Tenis": 450,
            "Basket": 500,
            "Hiking": 400,
            "Menari": 400
        ]
    }
    
    static func estimatedCalories(for exercise: String, durationMinutes: Int) -> Int {
        let baseCalories = Olahraga.estimatedCalories[exercise] ?? 300
        // Estimate calories based on 60-minute base
        return (baseCalories * durationMinutes) / 60
    }
    
    // MARK: - Persistence
    private func loadWorkoutLogs() {
        workoutLogs = storage.loadWorkoutLogs()
    }
    
    private func saveWorkoutLogs() {
        storage.saveWorkoutLogs(workoutLogs)
    }
}
