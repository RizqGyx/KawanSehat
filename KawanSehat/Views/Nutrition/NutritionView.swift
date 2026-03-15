import SwiftUI

// MARK: - NutritionView
/// Feature 1: Food search, nutrition info, and healthy/cheap alternatives.
/// Sub-components live in Views/Components/Nutrition/.
struct NutritionView: View {
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    
    @StateObject private var geminiService = GeminiService.shared
    @State private var showHistorySheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
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
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                                
                                // AI Suggestion button
                                Button {
                                    Task {
                                        _ = await geminiService.getHealthSuggestion(
                                            for: selectedFood.name,
                                            userProfile: userProfileVM.profile
                                        )
                                    }
                                } label: {
                                    if geminiService.isLoading {
                                        ProgressView()
                                            .frame(height: 16)
                                    } else {
                                        Label("AI Saran", systemImage: "sparkles")
                                    }
                                }
                                .font(.caption)
                                .disabled(geminiService.isLoading)
                            }
                            .padding(.horizontal)
                            
                            // Nutrition result card
                            NutritionResultCard(
                                food: selectedFood,
                                budgetStatus: nutritionVM.budgetRemainingFormatted,
                                fitsBudget: nutritionVM.fitsbudget(selectedFood),
                                caloriePercentage: nutritionVM.caloriePercentage(for: selectedFood),
                                tdee: userProfileVM.profile.tdee
                            )
                            .padding(.horizontal)
                            
                            // Gemini suggestion section (if available)
                            if let latestSuggestion = geminiService.suggestions.first,
                               latestSuggestion.foodName == selectedFood.name {
                                GeminiSuggestionCard(suggestion: latestSuggestion)
                                    .padding(.horizontal)
                            }
                            
                            // Alternative suggestions section
                            if !nutritionVM.suggestions.isEmpty {
                                AlternativeHeaderSection()
                                
                                VStack(spacing: 10) {
                                    ForEach(nutritionVM.suggestions) { suggestion in
                                        SuggestionCard(suggestion: suggestion) {
                                            withAnimation { nutritionVM.selectFood(suggestion.food) }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            } else {
                                ContentUnavailableView(
                                    "Tidak ada alternatif",
                                    systemImage: "checkmark.circle.fill",
                                    description: Text("Ini sudah pilihan terbaik sesuai budgetmu!")
                                )
                            }
                            
                            Spacer(minLength: 24)
                        }
                        .padding(.top, 4)
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
            
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showHistorySheet = true
                    } label: {
                        Label("History", systemImage: "deskclock")
                    }
                }
            }
            .onAppear {
                nutritionVM.updateProfile(userProfileVM.profile)
                nutritionVM.performSearch()
                geminiService.loadHistory()
            }
            .onChange(of: nutritionVM.searchQuery) { _, _ in
                nutritionVM.performSearch()
            }
            .sheet(isPresented: $showHistorySheet) {
                GeminiHistorySheet(geminiService: geminiService)
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
    
    // MARK: - Suggestion Card
//    struct SuggestionCard: View {
//        let suggestion: FoodSuggestion
//        let onTap: () -> Void
//        
//        var body: some View {
//            Button(action: onTap) {
//                HStack(spacing: 12) {
//                    // Green leaf icon for healthy alternative
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.green.opacity(0.15))
//                            .frame(width: 44, height: 44)
//                        Image(systemName: "leaf.fill")
//                            .foregroundColor(.green)
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(suggestion.food.name)
//                            .font(.subheadline.bold())
//                            .foregroundColor(.primary)
//                        Text(suggestion.reason)
//                            .font(.caption)
//                            .foregroundColor(.green)
//                        Text(suggestion.food.macroSummary)
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                    }
//                    
//                    Spacer()
//                    
//                    VStack(alignment: .trailing, spacing: 4) {
//                        Text(suggestion.food.priceFormatted)
//                            .font(.subheadline.bold())
//                            .foregroundColor(.green)
//                        if suggestion.savingsIDR > 0 {
//                            Text(suggestion.savingsFormatted)
//                                .font(.caption)
//                                .foregroundColor(.blue)
//                        }
//                        Text("\(Int(suggestion.food.calories)) kal")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                    }
//                }
//                .padding()
//                .background(Color(.systemBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .shadow(color: .black.opacity(0.05), radius: 4)
//            }
//            .buttonStyle(.plain)
//        }
//    }
}

// MARK: - Preview
#Preview {
    NutritionView()
        .environmentObject(NutritionViewModel(userProfile: UserProfile()))
        .environmentObject(UserProfileViewModel())
}

