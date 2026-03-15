//
//  MealSuggestionCard.swift
//  KawanSehat
//
//  Created by Farhan Izzaz on 14/03/26.
//
import SwiftUI
struct MealSuggestionCard: View {
    let food: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(food.name)
                    .font(.custom("Urbanist-bold", size: 13))
                    .foregroundColor(Color.textDark)
                Spacer()
                Image(systemName: "arrow.forward")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(Color.textDark)
            }
            
            Text(food.priceFormatted)
                .font(.custom("Urbanist-bold", size: 12))
                .foregroundStyle(Color.textMuted)
            Divider()
                .frame(height: 2)
                .background(Color.textDark.opacity(0.4))
            HStack {
                VStack(alignment: .leading) {
                    Text(String(format: "%.0f Kkal", food.calories))
                        .font(.custom("Urbanist-bold", size: 10))
                        .foregroundStyle(Color.brandSecondaryDark)
                    Text("calories")
                        .font(.custom("Urbanist", size: 10))
                        .foregroundStyle(Color.textDark)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text(String(format: "%.0f g", food.proteinG))
                        .font(.custom("Urbanist-bold", size: 10))
                        .foregroundStyle(Color.brandGreenDark)
                    Text("protein")
                        .font(.custom("Urbanist", size: 10))
                        .foregroundStyle(Color.textDark)
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(String(format: "%.0f g", food.carbsG))
                        .font(.custom("Urbanist-bold", size: 10))
                        .foregroundStyle(Color.error)
                    Text("karbohidrat")
                        .font(.custom("Urbanist", size: 10))
                        .foregroundStyle(Color.textDark)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text(String(format: "%.0f Kkal", food.fatG))
                        .font(.custom("Urbanist-bold", size: 10))
                        .foregroundStyle(Color.brandAccent)
                    Text("lemak")
                        .font(.custom("Urbanist", size: 10))
                        .foregroundStyle(Color.textDark)
                }
            }
        }
        .padding()
        .frame(width: 130, height: 130)
        .background(Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

#Preview {
    MealSuggestionCard(food: FoodItem(
        name: "Nasi Putih",
        nameEn: "Steamed White Rice",
        category: .rice,
        servingSizeG: 200,
        priceIDR: 5000,
        calories: 260,
        proteinG: 4.3,
        carbsG: 57.0,
        fatG: 0.4,
        fiberG: 0.6,
        healthScore: 5,
        tags: ["rice", "carb", "staple"]
    ))
}

