import SwiftUI

// MARK: - NutritionView
/// Feature 1: Food search, nutrition info, and healthy/cheap alternatives.
/// Sub-components live in Views/Components/Nutrition/.
struct NutritionView: View {
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
<<<<<<< Updated upstream
    
=======
    @StateObject private var geminiService = GeminiService.shared
    @State private var showHistorySheet = false

>>>>>>> Stashed changes
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                if let selectedFood = nutritionVM.selectedFood {
<<<<<<< Updated upstream
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
=======
                    // ── Detail state ───────────────────────────────────────
                    detailNavBar(for: selectedFood)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
>>>>>>> Stashed changes
                            NutritionResultCard(
                                food: selectedFood,
                                budgetStatus: nutritionVM.budgetRemainingFormatted,
                                fitsBudget: nutritionVM.fitsbudget(selectedFood),
                                caloriePercentage: nutritionVM.caloriePercentage(for: selectedFood),
                                tdee: userProfileVM.profile.tdee
                            )
<<<<<<< Updated upstream
                            .padding(.horizontal)
                            
                            // Suggestions section
                            if !nutritionVM.suggestions.isEmpty {
                                SectionHeader(title: "Alternatif Lebih Sehat & Hemat", icon: "sparkles")
                                
=======
                            .padding(.horizontal, 20)

                            if let latestSuggestion = geminiService.suggestions.first,
                               latestSuggestion.foodName == selectedFood.name {
                                GeminiSuggestionCard(suggestion: latestSuggestion)
                                    .padding(.horizontal, 20)
                            }

                            if !nutritionVM.suggestions.isEmpty {
                                AlternativeHeaderSection()
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
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
=======
                    // ── List state ─────────────────────────────────────────
                    listNavBar

                    HStack {
                        Text("Kalkulator Nutrisi")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.onBoardingPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                    NutritionSearchBar(text: $nutritionVM.searchQuery, onSubmit: {
                        nutritionVM.performSearch()
                    })
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    listContent
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
>>>>>>> Stashed changes
            .onAppear {
                nutritionVM.updateProfile(userProfileVM.profile)
                nutritionVM.performSearch()
            }
            .onChange(of: nutritionVM.searchQuery) { _, _ in
                nutritionVM.performSearch()
            }
        }
    }

<<<<<<< Updated upstream
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
=======
    // MARK: - Sub-views

    /// Navigation bar for the list screen (logo + History button)
    private var listNavBar: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)

            Text("KawanSehat")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.onBoardingPrimary)

            Spacer()

            Button { showHistorySheet = true } label: {
                Text("History")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.onBoardingPrimary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    /// Navigation bar for the detail screen (back button + title + AI button)
    @ViewBuilder
    private func detailNavBar(for food: FoodItem) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { nutritionVM.clearSelection() }
            } label: {
>>>>>>> Stashed changes
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)
                }
            }

            Text("Kalkulator Nutrisi")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.onBoardingPrimary)

            Spacer()

<<<<<<< Updated upstream
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
=======
            Button {
                Task {
                    _ = await geminiService.getHealthSuggestion(
                        for: food.name,
                        userProfile: userProfileVM.profile
                    )
                }
            } label: {
                if geminiService.isLoading {
                    ProgressView().frame(width: 20, height: 20)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.onBoardingTitle)
                }
            }
            .disabled(geminiService.isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    /// Search results list content
    @ViewBuilder
    private var listContent: some View {
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
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(nutritionVM.searchResults) { food in
                        FoodListRow(
                            food: food,
                            fitsBudget: nutritionVM.fitsbudget(food)
                        ) {
                            withAnimation { nutritionVM.selectFood(food) }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NutritionView()
        .environmentObject(NutritionViewModel(userProfile: UserProfile()))
        .environmentObject(UserProfileViewModel())
}
>>>>>>> Stashed changes
