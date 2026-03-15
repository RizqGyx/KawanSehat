//
//  GreetingBanner.swift
//  KawanSehat
//
//  Created by Farhan Izzaz on 14/03/26.
//
import SwiftUI

struct GreetingBanner: View {
    @EnvironmentObject var userVM: UserProfileViewModel

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Selamat Pagi"
        case 12..<15: return "Selamat Siang"
        case 15..<18: return "Selamat Sore"
        default: return "Selamat Malam"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Halo, \(userVM.profile.name)")
                    .font(.custom("Urbanist-bold", size: 20))
                    .foregroundStyle(Color.textDark)
                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                Color(
                                    UIColor(rgb: 0xF7F7F7).withAlphaComponent(
                                        0.32
                                    )
                                )
                            )
                            .frame(width: 150, height: 150)
                        Circle()
                            .fill(
                                Color(
                                    UIColor(rgb: 0xF7F7F7).withAlphaComponent(
                                        0.64
                                    )
                                )
                            )
                            .frame(width: 117, height: 117)
                        VStack {
                            Text("BMI")
                                .font(.custom("Urbanist-bold", size: 20))
                                .foregroundStyle(Color.textDark)
                            Text(String(format: "%.01f", userVM.profile.bmi))
                                .font(.custom("Urbanist-bold", size: 32))
                                .foregroundStyle(userVM.profile.bmiColor)
                            Text(userVM.profile.bmiCategory)
                                .font(.custom("Urbanist-bold", size: 14))
                                .foregroundStyle(userVM.profile.bmiColor)
                        }
                    }
                    ZStack {
                        Circle()
                            .fill(
                                Color(
                                    UIColor(rgb: 0xF7F7F7).withAlphaComponent(
                                        0.32
                                    )
                                )
                            )
                            .frame(width: 150, height: 150)
                        Circle()
                            .fill(
                                Color(
                                    UIColor(rgb: 0xF7F7F7).withAlphaComponent(
                                        0.64
                                    )
                                )
                            )
                            .frame(width: 117, height: 117)
                        VStack {
                            HStack(alignment: .bottom, spacing: 0) {
                                Text("Kalori")
                                    .font(.custom("Urbanist-bold", size: 20))
                                    .foregroundStyle(Color.textDark)
                                Text("/hari")
                                    .font(.custom("Urbanist-bold", size: 10))
                                    .foregroundStyle(Color.textDark)
                                    .alignmentGuide(.bottom) { d in
                                        d[.bottom] + 3
                                    }
                            }
                            Text(userVM.profile.dailyCaloriesFormatted)
                                .font(.custom("Urbanist-bold", size: 32))
                                .foregroundStyle(
                                    Color(UIColor(rgb: 0xffFF_8D28))
                                )
                            Text("kkal")
                                .font(.custom("Urbanist-bold", size: 14))
                                .foregroundStyle(
                                    Color(UIColor(rgb: 0xffFF_8D28))
                                )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(
                Color(Color.brandSecondary)
            )
            .clipShape(
                RoundedCorner(radius: 12, corners: [.topLeft, .topRight])
            )
            .padding(.horizontal)
            HStack {
                HStack(alignment: .bottom, spacing: 0) {
                    Text("Budget")
                        .font(.custom("Urbanist-bold", size: 20))
                        .foregroundStyle(Color(UIColor(rgb: 0x73957F)))
                    Text("/makan")
                        .font(.custom("Urbanist-bold", size: 10))
                        .foregroundStyle(Color(UIColor(rgb: 0x73957F)))
                        .alignmentGuide(.bottom) { d in
                            d[.bottom] + 3
                        }
                }
                Spacer()
                Text(userVM.profile.budgetPerMealFormatted)
                    .foregroundStyle(Color.brandGreenButton)
                    .font(.custom("Urbanist-bold", size: 20))
            }
            .padding()
            .background(
                Color(Color.brandGreenLight)
            )
            .clipShape(
                RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight])
            )
            .padding(.horizontal)
        }
    }
}

#Preview {
    GreetingBanner()
        .environmentObject(UserProfileViewModel())
}
