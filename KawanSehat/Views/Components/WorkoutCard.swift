//
//  WorkoutCard.swift
//  KawanSehat
//
//  Created by Farhan Izzaz on 14/03/26.
//

import SwiftUI
struct WorkoutCard: View {
    let workout: WorkoutSuggestion
    
    var body: some View {
        HStack(spacing: 12) {
            // Modern icon background
            ZStack {
                Circle()
                    .fill(
                        Color(UIColor(rgb: 0xFFF7F7F7)
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: workout.icon)
                    .foregroundColor(Color.textDark)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(workout.name)
                        .font(.custom("Urbanist-bold", size: 16))
                        .foregroundStyle(Color.textDark)
                }
                Text(workout.description)
                    .font(.custom("Urbanist-bold", size: 13))
                    .foregroundStyle(Color(UIColor(rgb: 0xFF98804A)))
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("-\(workout.caloriesBurned) kkal")
                    .font(.custom("Urbanist-bold", size: 12))
                    .foregroundColor(Color.error)
                Label("\(workout.caloriesBurned) menit", systemImage: "clock.fill")
                    .font(.custom("Urbanist-bold", size: 12))
                    .foregroundColor(Color(UIColor(rgb: 0xFF98804A)))
            }
        }
        .padding()
        .background(Color(UIColor(rgb: 0xFFFADDAD)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

#Preview {
    WorkoutCard(workout: WorkoutSuggestion(
        name: "Lari", durationMinutes: 60, caloriesBurned: 300, difficulty: "Sulit", icon: "figure.run", isFree: true, description: "Lorem ipsum"
    ))
}
