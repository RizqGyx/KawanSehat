import SwiftUI

// MARK: - NutritionView
/// Feature 1: Food search, nutrition info, and healthy/cheap alternatives.
/// Sub-components live in Views/Components/Nutrion/
struct NutritionView: View {
    @EnvironmentObject var nutritionVM: NutritionViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @StateObject private var geminiService = GeminiService.shared
    @State private var showHistorySheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                if let selectedFood = nutritionVM.selectedFood {
                    // ── Detail state: back button nav bar ─────────────────
                    detailNavBar(for: selectedFood)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            NutritionResultCard(
                                food: selectedFood,
                                budgetStatus: nutritionVM.budgetRemainingFormatted,
                                fitsBudget: nutritionVM.fitsbudget(selectedFood),
                                caloriePercentage: nutritionVM.caloriePercentage(for: selectedFood),
                                tdee: userProfileVM.profile.tdee
                            )
                            .padding(.horizontal, 20)

                            if let latestSuggestion = geminiService.suggestions.first,
                               latestSuggestion.foodName == selectedFood.name {
                                GeminiSuggestionCard(suggestion: latestSuggestion)
                                    .padding(.horizontal, 20)
                            }

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
                    // ── List state: custom header + search + list ──────────
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

    // MARK: - Sub-views

    /// Custom nav bar untuk halaman list (logo KawanSehat + tombol History)
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

    /// Custom nav bar untuk halaman detail (back button + judul + AI button)
    @ViewBuilder
    private func detailNavBar(for food: FoodItem) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { nutritionVM.clearSelection() }
            } label: {
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

    /// Konten list hasil pencarian
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
<<<<<<< HEAD
}
=======
}
>>>>>>> de1bca1a48f5b78133077f1a1eafddafd6bcc1c3
