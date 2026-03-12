import SwiftUI

// MARK: - Budget View
struct BudgetView: View {
    @EnvironmentObject var budgetVM: BudgetViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @State private var showAddExpenseSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Budget Summary Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sisa Budget Bulan Ini")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(budgetVM.remainingBudgetFormatted)
                                    .font(.title2.bold())
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("Total: \(budgetVM.totalSpentFormatted)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("dari \(String(format: "Rp%.0f", budgetVM.monthlyBudget))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        ProgressView(value: budgetVM.budgetPercentage)
                            .tint(budgetVM.budgetPercentage > 0.8 ? .red : budgetVM.budgetPercentage > 0.5 ? .orange : .green)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)
                    
                    // Add Expense Button
                    Button(action: { showAddExpenseSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Tambah Pengeluaran")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.subheadline.bold())
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    
                    // Category Breakdown
                    VStack(spacing: 12) {
                        Text("Pengeluaran per Kategori")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            let amount = budgetVM.expensesByCategory(category)
                            if amount > 0 {
                                CategoryExpenseRow(
                                    category: category,
                                    amount: amount
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Expenses List
                    if !budgetVM.thisMonthExpenses.isEmpty {
                        VStack(spacing: 12) {
                            Text("Riwayat Pengeluaran")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(budgetVM.thisMonthExpenses, id: \.id) { expense in
                                    ExpenseRow(
                                        expense: expense,
                                        onDelete: {
                                            budgetVM.removeExpense(expense)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "wallet.pass.fill")
                                .font(.title)
                                .foregroundColor(.green.opacity(0.5))
                            Text("Belum ada pengeluaran bulan ini")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .navigationTitle("Anggaran")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddExpenseSheet) {
                AddExpenseSheet(budgetVM: _budgetVM, isPresented: $showAddExpenseSheet)
            }
            .onAppear {
                budgetVM.updateProfile(userProfileVM.profile)
            }
        }
    }
}

// MARK: - Category Expense Row
struct CategoryExpenseRow: View {
    let category: ExpenseCategory
    let amount: Double
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.subheadline)
                    .foregroundColor(category.color == "orange" ? .orange :
                                   category.color == "red" ? .red :
                                   category.color == "purple" ? .purple :
                                   category.color == "green" ? .green : .gray)
                    .frame(width: 24)
                
                Text(category.rawValue)
                    .font(.subheadline)
            }
            
            Spacer()
            
            Text("Rp\(Int(amount))")
                .font(.subheadline.bold())
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Expense Row
struct ExpenseRow: View {
    let expense: Expense
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: expense.category.icon)
                        .foregroundColor(expense.category.color == "orange" ? .orange :
                                       expense.category.color == "red" ? .red :
                                       expense.category.color == "purple" ? .purple :
                                       expense.category.color == "green" ? .green : .gray)
                        .frame(width: 20)
                    
                    Text(expense.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.subheadline.bold())
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Rp\(Int(expense.amount))")
                    .font(.subheadline.bold())
                    .foregroundColor(.red)
                
                Text(expense.dateFormatted)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red.opacity(0.6))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Add Expense Sheet
struct AddExpenseSheet: View {
    @EnvironmentObject var budgetVM: BudgetViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedCategory = ExpenseCategory.food
    @State private var amount = ""
    @State private var note = ""
    
    var isValid: Bool {
        Double(amount) != nil && Double(amount)! > 0 && !note.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Kategori") {
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("Jumlah") {
                    HStack {
                        Text("Rp")
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Catatan") {
                    TextField("Contoh: Suplemen untuk kesehatan", text: $note)
                }
                
                Section {
                    Button(action: {
                        budgetVM.addExpense(
                            category: selectedCategory,
                            amount: Double(amount) ?? 0,
                            note: note
                        )
                        isPresented = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Tambah")
                                .font(.headline)
                            Spacer()
                        }
                        .foregroundColor(.blue)
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Tambah Pengeluaran")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    BudgetView()
        .environmentObject(BudgetViewModel(userProfile: UserProfile()))
        .environmentObject(UserProfileViewModel())
}
