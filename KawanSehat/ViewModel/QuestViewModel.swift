import Foundation
import SwiftUI
import Combine

// MARK: - QuestViewModel
@MainActor
class QuestViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var quests: [Quest] = []
    
    private let storage = UserDefaultsService.shared
    
    init() {
        loadQuests()
        initializeDailyQuests()
    }
    
    // MARK: - Initialize Daily Quests
    /// Create today's quests if they don't exist
    private func initializeDailyQuests() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we already have quests for today
        let todayQuests = quests.filter { calendar.isDate($0.createdDate, inSameDayAs: today) }
        
        if todayQuests.isEmpty {
            // Create daily quests
            for questType in QuestType.allCases {
                let newQuest = Quest(type: questType, completed: false, createdDate: Date())
                quests.append(newQuest)
            }
            saveQuests()
        }
    }
    
    // MARK: - Get Today's Quests
    var todayQuests: [Quest] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return quests.filter { quest in
            calendar.isDate(quest.createdDate, inSameDayAs: today)
        }
    }
    
    // MARK: - Get Active (Incomplete) Quests
    var activeQuests: [Quest] {
        todayQuests.filter { !$0.completed }
    }
    
    // MARK: - Completed Quests Today
    var completedQuestsToday: [Quest] {
        todayQuests.filter { $0.completed }
    }
    
    var completedQuestCount: Int {
        completedQuestsToday.count
    }
    
    // MARK: - Check and Update Quest Completion
    func checkAndUpdateQuests(
        water2LDrunk: Bool,
        threeeMealsLogged: Bool,
        workout30MinDone: Bool,
        sleep7HoursDone: Bool,
        stayInBudget: Bool
    ) {
        var updatedQuests = quests
        
        for (index, quest) in updatedQuests.enumerated() {
            if !quest.completed && quest.isToday {
                var shouldComplete = false
                
                switch quest.type {
                case .drink2L:
                    shouldComplete = water2LDrunk
                case .eatThreeMeals:
                    shouldComplete = threeeMealsLogged
                case .workout30Min:
                    shouldComplete = workout30MinDone
                case .sleep7Hours:
                    shouldComplete = sleep7HoursDone
                case .stayInBudget:
                    shouldComplete = stayInBudget
                }
                
                if shouldComplete {
                    updatedQuests[index] = Quest(
                        id: quest.id,
                        type: quest.type,
                        completed: true,
                        completedDate: Date(),
                        createdDate: quest.createdDate
                    )
                }
            }
        }
        
        quests = updatedQuests
        saveQuests()
    }
    
    // MARK: - Manually Complete Quest
    func completeQuest(_ quest: Quest) {
        if let index = quests.firstIndex(where: { $0.id == quest.id }) {
            quests[index] = Quest(
                id: quest.id,
                type: quest.type,
                completed: true,
                completedDate: Date(),
                createdDate: quests[index].createdDate
            )
            saveQuests()
        }
    }
    
    // MARK: - Calculate Total XP from Completed Quests
    var totalXPEarned: Int {
        completedQuestsToday.reduce(0) { $0 + $1.type.reward }
    }
    
    // MARK: - Persistence
    private func loadQuests() {
        quests = storage.loadQuests()
    }
    
    private func saveQuests() {
        storage.saveQuests(quests)
    }
}

