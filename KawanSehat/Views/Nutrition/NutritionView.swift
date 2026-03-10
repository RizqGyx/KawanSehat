import SwiftUI

// MARK: - NutritionView
/// Feature 1: Food search, nutrition info, and healthy/cheap alternatives
struct NutritionView: View {
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $nutritionVM.searchQuery, onSubmit: {
                    nutritionVM.performSearch()
                })
                .padding()
                
                if let selectedFood = nutritionVM.selectedFood {
                    // Show selected food detail + suggestions
                    ScrollView {
                        VStack(spacing: 16) {
                            // Back to search button
                            HStack {
                                Button {
                                    withAnimation { nutritionVM.clearSelection() }
                                } label: {
                                    Label("Kembali ke pencarian", systemImage: "arrow.left")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Nutrition result card
                            NutritionResultCard(
                                food: selectedFood,
                                budgetStatus: nutritionVM.budgetRemainingFormatted,
                                fitsBudget: nutritionVM.fitsbudget(selectedFood),
                                caloriePercentage: nutritionVM.caloriePercentage(for: selectedFood)
                            )
                            .padding(.horizontal)
                            
                            // Suggestions section
                            if !nutritionVM.suggestions.isEmpty {
                                SectionHeader(title: "Alternatif Lebih Sehat & Hemat", icon: "sparkles")
                                
                                VStack(spacing: 10) {
                                    ForEach(nutritionVM.suggestions) { suggestion in
                                        SuggestionCard(suggestion: suggestion) {
                                            // Tap to select the alternative
                                            withAnimation {
                                                nutritionVM.selectFood(suggestion.food)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                ContentUnavailableView(
                                    "Tidak ada alternatif",
                                    systemImage: "checkmark.circle.fill",
                                    description: Text("Ini sudah pilihan terbaik sesuai budgetmu!")
                                )
                            }
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.top)
                    }
                } else {
                    // Show search results list
                    if nutritionVM.isSearching {
                        ProgressView("Mencari...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if nutritionVM.searchResults.isEmpty {
                        ContentUnavailableView(
                            "Tidak ditemukan",
                            systemImage: "magnifyingglass",
                            description: Text("Coba kata kunci lain seperti 'nasi', 'ayam', 'tempe'")
                        )
                    } else {
                        List(nutritionVM.searchResults) { food in
                            FoodListRow(
                                food: food,
                                fitsBudget: nutritionVM.fitsbudget(food)
                            ) {
                                withAnimation {
                                    nutritionVM.selectFood(food)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Kalkulator Nutrisi")
            .onAppear {
                // Sync with latest profile (budget may have changed)
                nutritionVM.updateProfile(userProfileVM.profile)
                nutritionVM.performSearch()
            }
            .onChange(of: nutritionVM.searchQuery) { _, _ in
                nutritionVM.performSearch()
            }
        }
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Cari makanan (contoh: nasi goreng, tempe...)", text: $text)
                .submitLabel(.search)
                .onSubmit(onSubmit)
            if !text.isEmpty {
                Button {
                    text = ""
                    onSubmit()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Food List Row
struct FoodListRow: View {
    let food: FoodItem
    let fitsBudget: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Health score circle
                ZStack {
                    Circle()
                        .fill(healthColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text("\(food.healthScore)")
                        .font(.subheadline.bold())
                        .foregroundColor(healthColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Text("\(Int(food.calories)) kal · \(food.category.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(food.priceFormatted)
                        .font(.subheadline.bold())
                        .foregroundColor(fitsBudget ? .green : .orange)
                    if !fitsBudget {
                        Text("Melebihi budget")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
    
    var healthColor: Color {
        switch food.healthScore {
        case 8...10: return .green
        case 6...7:  return .blue
        case 4...5:  return .orange
        default:     return .red
        }
    }
}

// MARK: - Nutrition Result Card
struct NutritionResultCard: View {
    let food: FoodItem
    let budgetStatus: String
    let fitsBudget: Bool
    let caloriePercentage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.title2.bold())
                    Text(food.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(food.priceFormatted)
                        .font(.title3.bold())
                        .foregroundColor(fitsBudget ? .green : .orange)
                    Text(budgetStatus)
                        .font(.caption)
                        .foregroundColor(fitsBudget ? .secondary : .orange)
                }
            }
            
            Divider()
            
            // Calories with progress bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Kalori")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(food.calories)) kal")
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                    Text("(\(Int(caloriePercentage * 100))% dari kebutuhan harian)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: caloriePercentage)
                    .tint(.orange)
            }
            
            // Macros grid
            HStack(spacing: 0) {
                MacroCell(label: "Protein", value: food.proteinG, unit: "g", color: .blue)
                MacroCell(label: "Karbohidrat", value: food.carbsG, unit: "g", color: .orange)
                MacroCell(label: "Lemak", value: food.fatG, unit: "g", color: .pink)
                MacroCell(label: "Serat", value: food.fiberG, unit: "g", color: .green)
            }
            
            // Health score
            HStack {
                Label(food.healthScoreLabel, systemImage: "heart.fill")
                    .font(.subheadline)
                    .foregroundColor(.green)
                Spacer()
                Text("Per \(Int(food.servingSizeG))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8)
    }
}

// MARK: - Macro Cell
struct MacroCell: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f\(unit)", value))
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Suggestion Card
struct SuggestionCard: View {
    let suggestion: FoodSuggestion
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Green leaf icon for healthy alternative
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.food.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Text(suggestion.reason)
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(suggestion.food.macroSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(suggestion.food.priceFormatted)
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                    if suggestion.savingsIDR > 0 {
                        Text(suggestion.savingsFormatted)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    Text("\(Int(suggestion.food.calories)) kal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4)
        }
    }
}
