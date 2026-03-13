import SwiftUI

// MARK: - Makanan (Food) View
struct MakanView: View {
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @State private var showAddMealSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Nutrition Summary for today
                    VStack(spacing: 16) {
                        Text("Nutrisi Hari Ini")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Macro Cards
                        HStack(spacing: 12) {
                            MacroCard(
                                label: "Protein",
                                value: String(format: "%.0f", nutritionVM.todayTotalProteinG),
                                target: String(format: "%.0f", userProfileVM.profile.proteinTargetG),
                                percentage: nutritionVM.proteinPercentage(),
                                color: .red
                            )
                            
                            MacroCard(
                                label: "Karbo",
                                value: String(format: "%.0f", nutritionVM.todayTotalCarbsG),
                                target: String(format: "%.0f", userProfileVM.profile.carbsTargetG),
                                percentage: nutritionVM.carbsPercentage(),
                                color: .blue
                            )
                            
                            MacroCard(
                                label: "Lemak",
                                value: String(format: "%.0f", nutritionVM.todayTotalFatG),
                                target: String(format: "%.0f", userProfileVM.profile.fatTargetG),
                                percentage: nutritionVM.fatPercentage(),
                                color: .yellow
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)
                    
                    // Budget Makanan
                    VStack(spacing: 12) {
                        HStack {
                            Label("Budget Makanan", systemImage: "wallet.pass.fill")
                                .font(.subheadline.bold())
                                .foregroundColor(.green)
                            Spacer()
                            Text("\(nutritionVM.todayFoodSpentFormatted)/Rp\(Int(userProfileVM.profile.dailyBudgetIDR))")
                                .font(.subheadline.bold())
                                .foregroundColor(.green)
                        }
                        
                        // Progress bar for food budget
                        let budgetUsage = userProfileVM.profile.dailyBudgetIDR > 0 ? 
                            nutritionVM.todayTotalFoodSpent / userProfileVM.profile.monthlyBudgetIDR : 0
                        ProgressView(value: min(budgetUsage, 1.0))
                            .tint(budgetUsage > 0.8 ? .red : budgetUsage > 0.5 ? .orange : .green)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)
                    
                    // Calorie Summary
                    VStack(spacing: 12) {
                        HStack {
                            Label("Kalori Harian", systemImage: "flame.fill")
                                .font(.subheadline.bold())
                                .foregroundColor(.orange)
                            Spacer()
                            Text("\(Int(nutritionVM.todayTotalCalories))/\(Int(userProfileVM.profile.tdee))")
                                .font(.subheadline.bold())
                        }
                        
                        ProgressView(value: min(nutritionVM.todayTotalCalories / userProfileVM.profile.tdee, 1.0))
                            .tint(.orange)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)
                    
                    // Add Meal Button
                    Button(action: { showAddMealSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Tambah Makanan")
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
                    
                    // Today's Meals List
                    if !nutritionVM.todayMealLogs.isEmpty {
                        VStack(spacing: 12) {
                            Text("Makanan Hari Ini")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(nutritionVM.todayMealLogs, id: \.id) { meal in
                                    MealRow(meal: meal, onDelete: {
                                        nutritionVM.removeMealLog(meal)
                                    })
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "fork.knife")
                                .font(.title)
                                .foregroundColor(.blue.opacity(0.5))
                            Text("Belum ada makanan hari ini")
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
            .navigationTitle("Makan")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddMealSheet) {
                AddMealSheet(nutritionVM: _nutritionVM, userProfileVM: _userProfileVM, isPresented: $showAddMealSheet)
            }
        }
    }
}

// MARK: - Macro Card Component
struct MacroCard: View {
    let label: String
    let value: String
    let target: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.secondary)
            
            Text("\(value)g")
                .font(.headline.bold())
                .foregroundColor(color)
            
            ProgressView(value: percentage)
                .tint(color)
            
            Text("Target: \(target)g")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Meal Row Component
struct MealRow: View {
    let meal: MealLog
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.foodName)
                    .font(.subheadline.bold())
                HStack(spacing: 8) {
                    Text("\(Int(meal.calories)) kal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("\(Int(meal.priceIDR))")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("P:\(Int(meal.proteinG))g K:\(Int(meal.carbsG))g L:\(Int(meal.fatG))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(meal.dateFormatted)
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

// MARK: - Add Meal Sheet
struct AddMealSheet: View {
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @Binding var isPresented: Bool
    
    @State private var foodName = ""
    @State private var proteinG = ""
    @State private var carbsG = ""
    @State private var fatG = ""
    @State private var priceIDR = ""
    
    var calories: Double {
        let p = Double(proteinG) ?? 0
        let c = Double(carbsG) ?? 0
        let f = Double(fatG) ?? 0
        return (p * 4) + (c * 4) + (f * 9)
    }
    
    var isValid: Bool {
        !foodName.isEmpty &&
        Double(proteinG) != nil && Double(proteinG)! >= 0 &&
        Double(carbsG) != nil && Double(carbsG)! >= 0 &&
        Double(fatG) != nil && Double(fatG)! >= 0 &&
        Double(priceIDR) != nil && Double(priceIDR)! > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Nama Makanan") {
                    TextField("Contoh: Nasi Goreng", text: $foodName)
                }
                
                Section("Gizi") {
                    HStack {
                        Label("Protein", systemImage: "bolt.fill")
                            .foregroundColor(.red)
                        Spacer()
                        TextField("g", text: $proteinG)
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Label("Karbohidrat", systemImage: "bolt.fill")
                            .foregroundColor(.blue)
                        Spacer()
                        TextField("g", text: $carbsG)
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Label("Lemak", systemImage: "bolt.fill")
                            .foregroundColor(.yellow)
                        Spacer()
                        TextField("g", text: $fatG)
                            .keyboardType(.decimalPad)
                            .frame(width: 60)
                    }
                }
                
                Section("Preview") {
                    HStack {
                        Text("Total Kalori")
                        Spacer()
                        Text("\(Int(calories)) kal")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                    }
                }
                
                Section("Harga") {
                    HStack {
                        Text("Rp")
                        TextField("0", text: $priceIDR)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section {
                    Button(action: {
                        nutritionVM.addMealLog(
                            foodName: foodName,
                            proteinG: Double(proteinG) ?? 0,
                            carbsG: Double(carbsG) ?? 0,
                            fatG: Double(fatG) ?? 0,
                            calories: calories,
                            priceIDR: Double(priceIDR) ?? 0
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
            .navigationTitle("Tambah Makanan")
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
    MakanView()
        .environmentObject(NutritionViewModel(userProfile: UserProfile()))
        .environmentObject(UserProfileViewModel())
}
