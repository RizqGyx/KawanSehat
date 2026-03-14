import SwiftUI

// MARK: - MealReminderHistorySheet
struct MealReminderHistorySheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var mealReminderHistory: [MealReminderHistoryItem] = []

    private let storage = UserDefaultsService.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Custom header bar ────────────────────────────────────
                ZStack {
                    Text("Riwayat Rekomendasi")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)

                    HStack {
                        // Trash pill — only shown when list is non-empty
                        if !mealReminderHistory.isEmpty {
                            Button {
                                storage.clearMealReminderHistory()
                                withAnimation { mealReminderHistory.removeAll() }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 1.0, green: 0.92, blue: 0.92))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(red: 0.85, green: 0.20, blue: 0.20))
                                }
                            }
                        } else {
                            // Placeholder so title stays centered
                            Color.clear.frame(width: 44, height: 44)
                        }

                        Spacer()

                        // Close button — green circle with X
                        Button { dismiss() } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.onBoardingTitle)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 16)
                .background(Color(.systemBackground))

                Divider()

                // ── Content ──────────────────────────────────────────────
                if mealReminderHistory.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "Tidak ada riwayat",
                        systemImage: "clock.fill",
                        description: Text("Rekomendasi makanan dari AI akan muncul di sini")
                    )
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            ForEach(groupedSections, id: \.title) { section in
                                // Section header
                                HistorySectionHeader(title: section.title)
                                    .padding(.top, 8)

                                VStack(spacing: 10) {
                                    ForEach(section.items) { item in
                                        MealHistoryCard(item: item)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                    .background(Color.appBackground)
                }
            }
            .background(Color.appBackground)
            // Hide default navigation chrome — we use custom header
            .navigationBarHidden(true)
        }
        .onAppear { loadHistory() }
    }

    // MARK: - Grouping helpers

    private struct HistorySection {
        let title: String
        let items: [MealReminderHistoryItem]
    }

    private var groupedSections: [HistorySection] {
        let calendar = Calendar.current
        let today     = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        var todayItems:     [MealReminderHistoryItem] = []
        var yesterdayItems: [MealReminderHistoryItem] = []
        var olderItems:     [MealReminderHistoryItem] = []

        for item in mealReminderHistory {
            let itemDay = calendar.startOfDay(for: item.timestamp)
            if itemDay == today           { todayItems.append(item) }
            else if itemDay == yesterday  { yesterdayItems.append(item) }
            else                          { olderItems.append(item) }
        }

        var sections: [HistorySection] = []
        if !todayItems.isEmpty     { sections.append(.init(title: "HARI INI",   items: todayItems)) }
        if !yesterdayItems.isEmpty { sections.append(.init(title: "KEMARIN",    items: yesterdayItems)) }
        if !olderItems.isEmpty     { sections.append(.init(title: "LEBIH LAMA", items: olderItems)) }
        return sections
    }

    private func loadHistory() {
        mealReminderHistory = storage.loadMealReminderHistory()
    }
}

// MARK: - Meal History Card
struct MealHistoryCard: View {
    let item: MealReminderHistoryItem
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Collapsed header row ───────────────────────────────────
            HStack(spacing: 14) {
                // Icon box
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBgColor(item.mealType))
                        .frame(width: 50, height: 50)
                    Image(systemName: mealTypeIcon(item.mealType))
                        .font(.system(size: 22))
                        .foregroundColor(iconFgColor(item.mealType))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.mealType.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)
                    Text(formattedDate(item.timestamp))
                        .font(.system(size: 13))
                        .foregroundStyle(Color.onBoardingPrimary.opacity(0.50))
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.onBoardingPrimary.opacity(0.45))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }

            // ── Expanded detail ────────────────────────────────────────
            if isExpanded {
                Divider()
                    .padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 14) {
                    // Label + food name
                    VStack(alignment: .leading, spacing: 4) {
                        Text("REKOMENDASI")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.onBoardingPrimary.opacity(0.45))
                            .tracking(0.8)

                        Text(item.foodName.isEmpty ? "-" : item.foodName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.onBoardingTitle)
                    }

                    // Description (if any)
                    if !item.description.isEmpty {
                        Text(item.description)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.onBoardingPrimary.opacity(0.65))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // KALORI + BUDGET pill cards
                    HStack(spacing: 10) {
                        InfoPillCard(
                            label: "KALORI",
                            value: item.calorieInfo.isEmpty ? "-" : item.calorieInfo,
                            bgColor: Color(red: 0.99, green: 0.92, blue: 0.82),   // warm orange tint
                            labelColor: Color(red: 0.75, green: 0.40, blue: 0.08),
                            valueColor: Color(red: 0.55, green: 0.28, blue: 0.04)
                        )
                        InfoPillCard(
                            label: "BUDGET",
                            value: item.budgetInfo.isEmpty ? "-" : item.budgetInfo,
                            bgColor: Color(red: 0.49, green: 0.85, blue: 0.83),   // teal — matches nutrition card
                            labelColor: Color(red: 0.08, green: 0.40, blue: 0.38),
                            valueColor: Color(red: 0.05, green: 0.28, blue: 0.26)
                        )
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .transition(.opacity)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.onBoardingPrimary.opacity(0.07), radius: 6, x: 0, y: 2)
    }

    // MARK: - Icon helpers

    private func mealTypeIcon(_ mealType: MealRecommendation.MealType) -> String {
        switch mealType {
        case .breakfast: return "sunrise.fill"
        case .lunch:     return "sun.max.fill"
        case .dinner:    return "moon.fill"
        }
    }

    private func iconBgColor(_ mealType: MealRecommendation.MealType) -> Color {
        switch mealType {
        case .breakfast: return Color(red: 0.99, green: 0.92, blue: 0.82)  // warm peach
        case .lunch:     return Color(red: 0.99, green: 0.95, blue: 0.78)  // warm yellow
        case .dinner:    return Color(red: 0.49, green: 0.85, blue: 0.83)  // teal
        }
    }

    private func iconFgColor(_ mealType: MealRecommendation.MealType) -> Color {
        switch mealType {
        case .breakfast: return Color(red: 0.88, green: 0.55, blue: 0.10)
        case .lunch:     return Color(red: 0.80, green: 0.62, blue: 0.08)
        case .dinner:    return Color(red: 0.08, green: 0.42, blue: 0.40)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "id_ID")
        df.dateFormat = "d MMM yyyy • HH.mm"
        return df.string(from: date)
    }
}

// MARK: - InfoPillCard
/// Large two-line pill used inside expanded history card (Kalori / Budget)
struct InfoPillCard: View {
    let label: String
    let value: String
    let bgColor: Color
    let labelColor: Color
    let valueColor: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(labelColor)
                .tracking(0.6)
            Text(value)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MealReminderHistorySheet()
}
