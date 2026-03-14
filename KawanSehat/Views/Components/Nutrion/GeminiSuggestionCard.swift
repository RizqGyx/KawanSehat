import SwiftUI

// MARK: - GeminiSuggestionCard
/// Card showing the AI-powered suggestion for a selected food item.
struct GeminiSuggestionCard: View {
    let suggestion: GeminiSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("AI Recommendation", systemImage: "sparkles.square.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.purple)
                Spacer()
            }
            Text(suggestion.suggestion)
                .font(.callout)
                .foregroundColor(.primary)
            if !suggestion.alternatives.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Alternatif yang direkomendasikan:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    ForEach(suggestion.alternatives, id: \.self) { alt in
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundColor(.purple)
                            Text(alt).font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - GeminiHistorySheet
/// Sheet displaying the full history of AI food suggestions.
/// Styled consistently with MealReminderHistorySheet.
struct GeminiHistorySheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var geminiService: GeminiService

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Custom header bar ────────────────────────────────────
                ZStack {
                    Text("Riwayat Rekomendasi AI")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)

                    HStack {
                        // Trash — only when list is non-empty
                        if !geminiService.suggestions.isEmpty {
                            Button {
                                withAnimation { geminiService.clearHistory() }
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
                            Color.clear.frame(width: 44, height: 44)
                        }

                        Spacer()

                        // Close — green circle X
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
                if geminiService.suggestions.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 72, height: 72)
                            Image(systemName: "sparkles")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.onBoardingPrimary.opacity(0.45))
                        }
                        VStack(spacing: 6) {
                            Text("Tidak ada riwayat AI")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.onBoardingPrimary)
                            Text("Saran AI akan muncul di sini setelah kamu\nmenggunakan fitur AI Recommendation")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.onBoardingPrimary.opacity(0.50))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(groupedSections, id: \.title) { section in
                                HistorySectionHeader(title: section.title)
                                    .padding(.top, 8)

                                VStack(spacing: 10) {
                                    ForEach(section.items) { suggestion in
                                        GeminiHistoryCard(
                                            suggestion: suggestion,
                                            onDelete: { geminiService.deleteSuggestion(suggestion) }
                                        )
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
            .navigationBarHidden(true)
        }
    }

    // MARK: - Grouping helpers

    private struct AIHistorySection {
        let title: String
        let items: [GeminiSuggestion]
    }

    private var groupedSections: [AIHistorySection] {
        let calendar  = Calendar.current
        let today     = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        var todayItems:     [GeminiSuggestion] = []
        var yesterdayItems: [GeminiSuggestion] = []
        var olderItems:     [GeminiSuggestion] = []

        for item in geminiService.suggestions {
            let itemDay = calendar.startOfDay(for: item.timestamp)
            if itemDay == today           { todayItems.append(item) }
            else if itemDay == yesterday  { yesterdayItems.append(item) }
            else                          { olderItems.append(item) }
        }

        var sections: [AIHistorySection] = []
        if !todayItems.isEmpty     { sections.append(.init(title: "HARI INI",   items: todayItems)) }
        if !yesterdayItems.isEmpty { sections.append(.init(title: "KEMARIN",    items: yesterdayItems)) }
        if !olderItems.isEmpty     { sections.append(.init(title: "LEBIH LAMA", items: olderItems)) }
        return sections
    }
}

// MARK: - GeminiHistoryCard
struct GeminiHistoryCard: View {
    let suggestion: GeminiSuggestion
    let onDelete: () -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Collapsed header ───────────────────────────────────────
            HStack(spacing: 14) {
                // AI icon box — purple tint
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: "sparkles")
                        .font(.system(size: 22))
                        .foregroundColor(.purple)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(suggestion.foodName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.onBoardingPrimary)
                        .lineLimit(1)
                    Text(formattedDate(suggestion.timestamp))
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
                    // Suggestion text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SARAN AI")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.onBoardingPrimary.opacity(0.45))
                            .tracking(0.8)
                        Text(suggestion.suggestion)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.onBoardingPrimary.opacity(0.80))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Alternatives list
                    if !suggestion.alternatives.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ALTERNATIF")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.onBoardingPrimary.opacity(0.45))
                                .tracking(0.8)
                            ForEach(suggestion.alternatives, id: \.self) { alt in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(Color.onBoardingTitle)
                                    Text(alt)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.onBoardingPrimary.opacity(0.75))
                                }
                            }
                        }
                    }

                    // Delete button
                    Button {
                        withAnimation { onDelete() }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                            Text("Hapus")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(Color(red: 0.85, green: 0.20, blue: 0.20))
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

    private func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "id_ID")
        df.dateFormat = "d MMM yyyy • HH.mm"
        return df.string(from: date)
    }
}
