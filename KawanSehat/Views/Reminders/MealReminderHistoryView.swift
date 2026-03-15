//
//  MealReminderHistoryView.swift
//  KawanSehat
//
//  Created by Muhammad Rizki on 11/03/26.
//

import SwiftUI

// MARK: - Meal Reminder History Sheet
struct MealReminderHistorySheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var mealReminderHistory: [MealReminderHistoryItem] = []
    
    private let storage = UserDefaultsService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if mealReminderHistory.isEmpty {
                    ContentUnavailableView(
                        "Tidak ada history",
                        systemImage: "clock.fill",
                        description: Text("Rekomendasi makanan dari AI akan muncul di sini")
                    )
                } else {
                    List {
                        ForEach(mealReminderHistory) { item in
                            MealHistoryCard(item: item)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                    .padding(.horizontal, 0)
                }
            }
            .navigationTitle("Riwayat Rekomendasi Makanan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tutup") { dismiss() }
                }
                
                if !mealReminderHistory.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Hapus Semua") {
                            storage.clearMealReminderHistory()
                            mealReminderHistory.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            loadHistory()
        }
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
        VStack(alignment: .leading, spacing: 12) {
            // Header with meal type and time
            HStack {
                // Meal type icon
                Image(systemName: mealTypeIcon(item.mealType))
                    .font(.title3)
                    .foregroundColor(mealTypeColor(item.mealType))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.mealType.rawValue)
                        .font(.subheadline.bold())
                    Text(formattedDate(item.timestamp))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.snappy) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                Divider()
                
                // Food recommendation
                VStack(alignment: .leading, spacing: 10) {
                    // Food name
                    HStack {
                        Text("Rekomendasi")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.foodName)
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                            .lineLimit(1)
                    }
                    
                    // Description - fully visible
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Keterangan")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                        Text(item.description.isEmpty ? "-" : item.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)  // No truncation
                    }
                    
                    // Nutritional info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            InfoPill(
                                label: "Kalori",
                                value: item.calorieInfo.isEmpty ? "-" : item.calorieInfo,
                                color: .orange,
                                isEmpty: item.calorieInfo.isEmpty
                            )
                            
                            InfoPill(
                                label: "Budget",
                                value: item.budgetInfo.isEmpty ? "-" : item.budgetInfo,
                                color: .blue,
                                isEmpty: item.budgetInfo.isEmpty
                            )
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4)
    }
    
    private func mealTypeIcon(_ mealType: MealRecommendation.MealType) -> String {
        switch mealType {
        case .breakfast:
            return "sunrise.fill"
        case .lunch:
            return "sun.max.fill"
        case .dinner:
            return "sunset.fill"
        }
    }
    
    private func mealTypeColor(_ mealType: MealRecommendation.MealType) -> Color {
        switch mealType {
        case .breakfast:
            return .orange
        case .lunch:
            return .yellow
        case .dinner:
            return .indigo
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Info Pill Component
struct InfoPill: View {
    let label: String
    let value: String
    let color: Color
    var isEmpty: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.bold())
                .foregroundColor(isEmpty ? .gray : color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isEmpty ? Color.gray.opacity(0.1) : color.opacity(0.08))
        .cornerRadius(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    MealReminderHistorySheet()
}
