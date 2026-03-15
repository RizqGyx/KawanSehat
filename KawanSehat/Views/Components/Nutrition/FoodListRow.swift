import SwiftUI

// MARK: - FoodListRow
/// Single row in the nutrition search results list.
/// Wrapped in a card-style container matching the detail screen aesthetic.
struct FoodListRow: View {
    let food: FoodItem
    let fitsBudget: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Left: name + calorie meta
                VStack(alignment: .leading, spacing: 7) {
                    Text(food.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)

                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                        Text("\(Int(food.calories))Kal. \(food.category.rawValue)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.onBoardingPrimary.opacity(0.55))
                    }
                }

                Spacer()

                // Right: price + budget badge
                VStack(alignment: .trailing, spacing: 5) {
                    Text(food.priceFormatted)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)

                    if fitsBudget {
                        Text("Hemat Rp 5.000")
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
            // ── Card container (matches detail screen style) ──
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
