import SwiftUI

// MARK: - NutritionSearchBar
struct NutritionSearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.systemGray2))
                .font(.system(size: 16))
            TextField("Cari Makanan (Contoh: Ayam Penye...", text: $text)
                .font(.system(size: 15))
                .foregroundStyle(Color.onBoardingPrimary)
                .submitLabel(.search)
                .onSubmit(onSubmit)
            if !text.isEmpty {
                Button {
                    text = ""; onSubmit()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray3))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
