//
//  SectionHeader.swift
//  KawanSehat
//
//  Created by Farhan Izzaz on 14/03/26.
//
import SwiftUI
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
