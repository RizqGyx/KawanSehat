import SwiftUI

// MARK: - HistorySectionHeader
/// Reusable date section divider used in history sheets (Gemini & MealReminder).
struct HistorySectionHeader: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.onBoardingPrimary.opacity(0.15))
                .frame(height: 1)

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.onBoardingPrimary.opacity(0.45))
                .fixedSize()
                .tracking(0.8)

            Rectangle()
                .fill(Color.onBoardingPrimary.opacity(0.15))
                .frame(height: 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
}
