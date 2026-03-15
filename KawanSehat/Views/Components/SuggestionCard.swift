// MARK: - Suggestion Card (redesigned — flat card with tag chips)
struct SuggestionCard: View {
    let suggestion: FoodSuggestion
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 7) {
                    Text(suggestion.food.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)

                    // Tag chips: reason tokens
                    HStack(spacing: 8) {
                        TagChip(text: "Lebih Sehat")
                        TagChip(text: "Serat Tinggi")
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text(suggestion.food.priceFormatted)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)

                    // Budget badge
                    if suggestion.savingsIDR > 0 {
                        Text("Hemat \(suggestion.savingsFormatted)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.12, green: 0.55, blue: 0.22))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color(red: 0.86, green: 0.97, blue: 0.88))
                            .clipShape(Capsule())
                    } else {
                        Text("Boros Rp 5.000")
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