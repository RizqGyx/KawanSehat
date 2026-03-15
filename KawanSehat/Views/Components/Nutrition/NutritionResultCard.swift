import SwiftUI

// MARK: - NutritionResultCard
/// Main teal card shown on the food detail screen.
struct NutritionResultCard: View {
    let food: FoodItem
    let budgetStatus: String
    let fitsBudget: Bool
    let caloriePercentage: Double
    let tdee: Double

    // Solid teal background — matches design mockup exactly
    private let cardBg      = Color(red: 0.49, green: 0.85, blue: 0.83)  // #7DD9D3
    private let ratingBg    = Color(red: 0.80, green: 0.94, blue: 0.80)  // #CCF0CC
    private let tealDark    = Color(red: 0.08, green: 0.50, blue: 0.47)  // icon & progress fill
    private let labelGreen  = Color(red: 0.10, green: 0.44, blue: 0.20)  // "Kalori Harian" label

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Food identity row ──────────────────────────────────────
            HStack(alignment: .center, spacing: 14) {
                // Icon box — white card with shadow
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(tealDark)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Color.onBoardingPrimary)

                    // Category — plain text, no pill
                    Text(food.category.rawValue)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.onBoardingPrimary.opacity(0.70))
                }
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 16)

            // ── Calorie progress ───────────────────────────────────────
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Kalori Harian")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(labelGreen)
                    Spacer()
                    // e.g. "360 / 950 Kkal"
                    HStack(spacing: 2) {
                        Text("\(Int(food.calories))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.onBoardingPrimary)
                        Text("/ \(Int(tdee)) Kkal")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color.onBoardingPrimary.opacity(0.70))
                    }
                }

                // Thick progress track — white track, dark teal fill
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.60))
                            .frame(height: 12)
                        Capsule()
                            .fill(Color.onBoardingPrimary)
                            .frame(width: geo.size.width * min(caloriePercentage, 1.0), height: 12)
                    }
                }
                .frame(height: 12)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)

            // ── Macro grid (4 white boxes) ─────────────────────────────
            HStack(spacing: 10) {
                MacroBox(label: "KALORI",  value: "\(Int(food.calories))",               unit: "Kkal")
                MacroBox(label: "LEMAK",   value: String(format: "%.0f", food.fatG),     unit: "g")
                MacroBox(label: "KARBO",   value: String(format: "%.0f", food.carbsG),   unit: "g")
                MacroBox(label: "PROTEIN", value: String(format: "%.0f", food.proteinG), unit: "g")
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 12)

            // ── Health rating row — green-tinted bottom bar ────────────
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("RATING MAKANAN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.onBoardingPrimary.opacity(0.55))
                        .tracking(0.4)
                    HStack(spacing: 4) {
                        ForEach(0..<5) { i in
                            Image(systemName: starIcon(index: i, score: food.healthScore))
                                .font(.system(size: 15))
                                .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.20))
                        }
                    }
                }

                Spacer()

                // Badge pill
                Text(healthLabel(score: food.healthScore))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.onBoardingTitle)
                    .clipShape(Capsule())

                // Score text
                Text(String(format: "%.1f / 5.0", Double(food.healthScore) / 2.0))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.onBoardingPrimary.opacity(0.60))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(ratingBg)
            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
        }
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: cardBg.opacity(0.45), radius: 14, x: 0, y: 6)
    }

    private func starIcon(index: Int, score: Int) -> String {
        let stars = Double(score) / 2.0
        if Double(index) + 1.0 <= stars       { return "star.fill" }
        else if Double(index) < stars          { return "star.leadinghalf.filled" }
        else                                   { return "star" }
    }

    private func healthLabel(score: Int) -> String {
        switch score {
        case 9...10: return "Sangat Sehat"
        case 7...8:  return "Sehat"
        case 5...6:  return "Cukup Sehat"
        case 3...4:  return "Kurang Sehat"
        default:     return "Tidak Sehat"
        }
    }
}

// MARK: - MacroBox
struct MacroBox: View {
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color.onBoardingPrimary.opacity(0.55))
                .tracking(0.5)
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(Color.onBoardingPrimary)
            Text(unit)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.onBoardingPrimary.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - RoundedCorner Shape Helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
