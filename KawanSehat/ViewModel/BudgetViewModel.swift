import Foundation
import SwiftUI
import Combine

// MARK: - BudgetViewModel
@MainActor
class BudgetViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var expenses: [Expense] = []
    @Published var monthlyBudget: Double = 500000  // Default monthly budget
    
    private let storage = UserDefaultsService.shared
    
    init(userProfile: UserProfile) {
        self.monthlyBudget = userProfile.monthlyBudgetIDR
        loadExpenses()
    }
    
    // MARK: - Add Expense
    func addExpense(category: ExpenseCategory, amount: Double, note: String) {
        let newExpense = Expense(
            category: category,
            amount: amount,
            note: note
        )
        expenses.insert(newExpense, at: 0)
        saveExpenses()
    }
    
    // MARK: - Remove Expense
    func removeExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveExpenses()
    }
    
    // MARK: - Get This Month's Expenses
    var thisMonthExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        let thisMonth = calendar.dateComponents([.year, .month], from: now)
        
        return expenses.filter { expense in
            let expenseMonth = calendar.dateComponents([.year, .month], from: expense.date)
            return expenseMonth == thisMonth
        }
    }
    
    // MARK: - Calculate Total Spent This Month
    var totalSpentThisMonth: Double {
        thisMonthExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var totalSpentFormatted: String {
        return "Rp\(Int(totalSpentThisMonth))"
    }
    
    // MARK: - Remaining Budget
    var remainingBudget: Double {
        max(0, monthlyBudget - totalSpentThisMonth)
    }
    
    var remainingBudgetFormatted: String {
        return "Rp\(Int(remainingBudget))"
    }
    
    // MARK: - Budget Usage Percentage
    var budgetPercentage: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(totalSpentThisMonth / monthlyBudget, 1.0)
    }
    
    // MARK: - Expenses by Category
    func expensesByCategory(_ category: ExpenseCategory) -> Double {
        thisMonthExpenses
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Update Budget
    func updateMonthlyBudget(_ newBudget: Double) {
        monthlyBudget = newBudget
    }
    
    // MARK: - Persistence
    private func loadExpenses() {
        expenses = storage.loadExpenses()
    }
    
    private func saveExpenses() {
        storage.saveExpenses(expenses)
    }
    
    // MARK: - Update Profile
    func updateProfile(_ profile: UserProfile) {
        self.monthlyBudget = profile.monthlyBudgetIDR ?? 500000
    }
}

