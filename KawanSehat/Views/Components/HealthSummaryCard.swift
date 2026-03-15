//
//  HealthSummaryCard.swift
//  KawanSehat
//
//  Created by Farhan Izzaz on 14/03/26.
//

import SwiftUI
struct HealthSummaryCard: View {
    let vm: UserProfileViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Top section: BMI & Calories in modern layout
            HStack(spacing: 12) {
                // BMI Card
                VStack(spacing: 8) {
                    Text("BMI")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", vm.profile.bmi))
                        .font(.title.bold())
                        .foregroundColor(vm.bmiColor)
                    Text(vm.profile.bmiCategory)
                        .font(.caption2)
                        .foregroundColor(vm.bmiColor)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4)
                
                // Calories Card
                VStack(spacing: 8) {
                    Text("Kalori Harian")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f", vm.profile.tdee))
                        .font(.title.bold())
                        .foregroundColor(.orange)
                    Text("kal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4)
            }
            
            // Budget info
            HStack(spacing: 12) {
                Label("Budget per Makan", systemImage: "banknote")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Rp\(Int(vm.profile.budgetPerMealIDR))")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Activity level
            HStack(spacing: 8) {
                Image(systemName: "figure.walk.motion")
                    .foregroundColor(.blue)
                Text(vm.profile.activityLevel.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
