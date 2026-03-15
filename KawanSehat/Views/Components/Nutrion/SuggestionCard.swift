import SwiftUI

// MARK: - AlternativeHeaderSection
struct AlternativeHeaderSection: View {
    var body: some View {
        HStack {
            Text("Alternatif makanan lainnya")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.onBoardingPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }
}

// MARK: - SuggestionCard
/// Alternative food card — tampilan sama persis dengan FoodListRow di list utama.
struct SuggestionCard: View {
    let suggestion: FoodSuggestion
    let budgetPerMeal: Double   // userProfile.budgetPerMealIDR — untuk hitung selisih nyata
    let onTap: () -> Void

    private var fitsBudget: Bool {
        suggestion.food.priceIDR <= budgetPerMeal
    }

    private var budgetDiff: Double {
        budgetPerMeal - suggestion.food.priceIDR
    }

    private var budgetDiffFormatted: String {
        let amount = Int(abs(budgetDiff))
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "Rp \(formatted)"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Left: nama + kalori & kategori
                VStack(alignment: .leading, spacing: 7) {
                    Text(suggestion.food.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                        Text("\(Int(suggestion.food.calories))Kal. \(suggestion.food.category.rawValue)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.onBoardingPrimary.opacity(0.55))
                    }
                }

                Spacer()

                // Right: harga + badge hemat/boros
                VStack(alignment: .trailing, spacing: 5) {
                    Text(suggestion.food.priceFormatted)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)

                    if fitsBudget {
                        Text("Hemat \(budgetDiffFormatted)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.12, green: 0.55, blue: 0.22))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color(red: 0.86, green: 0.97, blue: 0.88))
                            .clipShape(Capsule())
                    } else {
                        Text("Boros \(budgetDiffFormatted)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.78, green: 0.18, blue: 0.18))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color(red: 0.99, green: 0.88, blue: 0.88))
                            .clipShape(Capsule())
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(.systemGray3))
                    .padding(.leading, 10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
