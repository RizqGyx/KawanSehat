import SwiftUI

// MARK: - ProfileView
struct ProfileView: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?

    enum Field { case weight, height, budget }

    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var budget: String = ""
    @State private var activity: ActivityLevel = .moderate

    // MARK: - Computed Properties

    private var bmi: Double? {
        guard let w = Double(weight), let h = Double(height), h > 0 else { return nil }
        return w / pow(h / 100, 2)
    }

    private var bmiCategory: String {
        guard let b = bmi else { return "–" }
        switch b {
        case ..<18.5: return "Kurus"
        case ..<25:   return "Normal"
        case ..<30:   return "Gemuk"
        default:      return "Obesitas"
        }
    }

    // Needle position 0–1, mapped BMI 14–40
    private var bmiGaugePosition: Double {
        guard let b = bmi else { return 0 }
        return max(0, min(1, (b - 14) / 26))
    }

    /// Rentang berat ideal berdasarkan BMI 18.5–24.9
    private var idealWeight: (min: Double, max: Double)? {
        guard let h = Double(height), h > 0 else { return nil }
        let hm = h / 100
        return (min: 18.5 * hm * hm, max: 24.9 * hm * hm)
    }

    private var weightStatus: (label: String, color: Color) {
        guard let w = Double(weight), let ideal = idealWeight else {
            return ("–", Color.textMuted)
        }
        if w < ideal.min            { return ("Kurang",        Color(red: 0.2, green: 0.6, blue: 0.9)) }
        else if w <= ideal.max      { return ("Ideal",         Color.onBoardingTitle) }
        else if w <= ideal.max + 5  { return ("Sedikit Lebih", Color(red: 1.0, green: 0.5, blue: 0.15)) }
        else                        { return ("Berlebih",      Color(red: 0.85, green: 0.15, blue: 0.15)) }
    }

    /// Inisial dari nama (maks 2 huruf)
    private var initials: String {
        let parts = vm.profile.name
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(vm.profile.name.prefix(1)).uppercased()
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.appBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection
                        VStack(spacing: 12) {
                            bodyDataCard
                            budgetCard
                            idealWeightCard
                            bmiCard
                            Spacer(minLength: 32)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 48)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrowshape.backward.fill")
                            .font(.custom("Urbanist-Bold", size: 16))
                            .foregroundStyle(Color.mainTabTint)
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                        .foregroundStyle(Color.textDark)
                }
            }
            .toolbarColorScheme(.light, for: .navigationBar)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Profil")
                        .font(.custom("Urbanist-Bold", size: 20))
                        .foregroundStyle(Color.mainTabTint)
                }
            }
            .onAppear {
                weight   = String(vm.profile.weightKg)
                height   = String(vm.profile.heightCm)
                budget   = String(Int(vm.profile.dailyBudgetIDR))
                activity = vm.profile.activityLevel
            }
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Gradient background (sama persis dengan HTML)
            LinearGradient(
                stops: [
                    .init(color: Color.brandGreenButton, location: 0.0),
                    .init(color: Color.onBoardingPrimary, location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            // Avatar + nama + pill aktivitas
            VStack(spacing: 10) {
                // Inisial saja — tidak ada tombol kamera
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 3)
                        .frame(width: 90, height: 90)
                    Circle()
                        .fill(.white)
                        .frame(width: 84, height: 84)
                    Text(initials)
                        .font(.custom("Urbanist-Bold", size: 32))
                        .foregroundStyle(Color.textDark)
                }

                Text(vm.profile.name)
                    .font(.custom("Urbanist-Bold", size: 20))
                    .foregroundStyle(.white)

                Text(activity.rawValue)
                    .font(.custom("Urbanist-Bold", size: 12))
                    .foregroundStyle(Color.appBackground)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(.top, 120)
            .padding(.bottom, 52)

            // Curved white overlap di bawah hero
            Color.appBackground
                .frame(height: 20)
                .clipShape(
                    ProfileRoundedCorner(radius: 20, corners: [.topLeft, .topRight])
                )
        }
    }

    // MARK: - Body Data Card
    private var bodyDataCard: some View {
        CardShell {
            cardHeader(icon: "figure.stand", title: "Data Tubuh")
            Divider().overlay(Color.fieldBackground)

            fieldRow(label: "Berat Badan") {
                TextField("65", text: $weight)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .weight)
                    .font(.custom("Urbanist-SemiBold", size: 15))
                    .foregroundStyle(Color.textDark)
                    .frame(width: 64)
                Text("kg").unitStyle()
            }
            Divider().overlay(Color.fieldBackground).padding(.leading, 16)

            fieldRow(label: "Tinggi Badan") {
                TextField("165", text: $height)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .height)
                    .font(.custom("Urbanist-SemiBold", size: 15))
                    .foregroundStyle(Color.textDark)
                    .frame(width: 64)
                Text("cm").unitStyle()
            }
            Divider().overlay(Color.fieldBackground).padding(.leading, 16)

            fieldRow(label: "Aktivitas") {
                Menu {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Button(level.rawValue) { activity = level }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(activity.rawValue)
                            .font(.custom("Urbanist-SemiBold", size: 12))
                            .foregroundStyle(Color.textDark)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.custom("Urbanist-Bold", size: 10))
                            .foregroundStyle(Color.textDark)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.brandGreenPale)
                    .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Ideal Weight Card
    private var idealWeightCard: some View {
        CardShell {
            cardHeaderNoEdit(icon: "scalemass", title: "Berat Badan Ideal")
            Divider().overlay(Color.fieldBackground)

            if let ideal = idealWeight, let w = Double(weight) {
                VStack(spacing: 0) {
                    // Rentang + status
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Rentang Ideal")
                                .font(.custom("Urbanist-Medium", size: 12))
                                .foregroundStyle(Color.textMuted)
                            Text("\(String(format: "%.1f", ideal.min)) – \(String(format: "%.1f", ideal.max)) kg")
                                .font(.custom("Urbanist-Bold", size: 18))
                                .foregroundStyle(Color.textDark)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text("Status")
                                .font(.custom("Urbanist-Medium", size: 10))
                                .foregroundStyle(Color.textMuted)
                            Text(weightStatus.label)
                                .font(.custom("Urbanist-Bold", size: 13))
                                .foregroundStyle(weightStatus.color)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(weightStatus.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    Divider().overlay(Color.fieldBackground).padding(.leading, 16)

                    // Selisih dari batas ideal
                    HStack {
                        Text("Berat Saat Ini")
                            .font(.custom("Urbanist-Medium", size: 13))
                            .foregroundStyle(Color.textMuted)
                        Spacer()
                        let diff = w - ideal.max
                        let diffLabel: String = {
                            if abs(diff) < 0.05 { return "Tepat di batas ideal" }
                            let prefix = diff > 0 ? "+" : ""
                            return "\(prefix)\(String(format: "%.1f", diff)) kg dari batas ideal"
                        }()
                        Text(diffLabel)
                            .font(.custom("Urbanist-SemiBold", size: 13))
                            .foregroundStyle(diff > 0.05 ? Color(red: 1.0, green: 0.5, blue: 0.15) : Color.textDark)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)

                    Divider().overlay(Color.fieldBackground).padding(.leading, 16)

                    // Visual bar
                    idealWeightBar(current: w, min: ideal.min, max: ideal.max)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }
            } else {
                Text("Masukkan berat dan tinggi badan untuk melihat berat ideal.")
                    .font(.custom("Urbanist-Bold", size: 13))
                    .foregroundStyle(Color.textMuted)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func idealWeightBar(current: Double, min: Double, max: Double) -> some View {
        let lo    = Swift.min(current, min) - 6
        let hi    = Swift.max(current, max) + 6
        let span  = hi - lo

        GeometryReader { geo in
            let totalW = geo.size.width

            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(Color.brandGreenPale.opacity(0.6))
                    .frame(height: 10)

                // Ideal range highlight
                let idealStart = CGFloat((min - lo) / span) * totalW
                let idealWidth = CGFloat((max - min) / span) * totalW
                Capsule()
                    .fill(Color.brandGreenDark.opacity(0.4))
                    .frame(width: Swift.max(idealWidth, 0), height: 10)
                    .offset(x: idealStart)

                // Current weight needle
                let needleX = CGFloat((current - lo) / span) * totalW - 9
                Circle()
                    .fill(.white)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color.textPrimary, lineWidth: 3))
                    .shadow(color: Color.textDark.opacity(0.3), radius: 4, y: 2)
                    .offset(x: Swift.max(0, Swift.min(needleX, totalW - 18)), y: -4)
            }
        }
        .frame(height: 18)
    }

    // MARK: - Budget Card
    private var budgetCard: some View {
        CardShell {
            cardHeader(icon: "creditcard", title: "Budget Harian")
            Divider().overlay(Color.fieldBackground)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("Rp")
                    .font(.custom("Urbanist-Medium", size: 14))
                    .foregroundStyle(Color.textMuted)
                TextField("50000", text: $budget)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .budget)
                    .font(.custom("Urbanist-Bold", size: 24))
                    .foregroundStyle(Color.textDark)
                Spacer()
                Text("/ hari")
                    .font(.custom("Urbanist-Medium", size: 12))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    // MARK: - BMI Card
    private var bmiCard: some View {
        CardShell {
            cardHeaderNoEdit(icon: "chart.line.uptrend.xyaxis", title: "Kalkulasi BMI")
            Divider().overlay(Color.fieldBackground)

            VStack(spacing: 0) {
                // Value + badge
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Indeks Massa Tubuh")
                            .font(.custom("Urbanist-Medium", size: 12))
                            .foregroundStyle(Color.textMuted)
                        Text(bmi.map { String(format: "%.1f", $0) } ?? "–")
                            .font(.custom("Urbanist-Bold", size: 38))
                            .foregroundStyle(Color.textDark)
                    }
                    Spacer()
                    VStack(spacing: 3) {
                        Text("Status")
                            .font(.custom("Urbanist-Medium", size: 10))
                            .foregroundStyle(Color.textMuted)
                        Text(bmiCategory)
                            .font(.custom("Urbanist-Bold", size: 14))
                            .foregroundStyle(Color.textDark)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.brandGreenPale)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 14)

                // Gauge bar
                bmiGaugeBar
                    .padding(.horizontal, 16)

                // Scale labels
                HStack {
                    ForEach(["Kurus", "Normal", "Gemuk", "Obesitas"], id: \.self) { label in
                        Text(label)
                            .font(.custom("Urbanist-Medium", size: 10))
                            .foregroundStyle(Color.textMuted.opacity(0.7))
                        if label != "Obesitas" { Spacer() }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 14)
            }
        }
    }

    private var bmiGaugeBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                LinearGradient(
                    colors: [
                        Color.brandGreenLight,
                        Color(red: 0.62, green: 0.88, blue: 0.2),
                        Color(red: 0.97, green: 0.78, blue: 0.24),
                        Color(red: 0.97, green: 0.37, blue: 0.12),
                        Color(red: 0.84, green: 0.14, blue: 0.14)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 10)
                .clipShape(Capsule())

                Circle()
                    .fill(.white)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color.textPrimary, lineWidth: 3))
                    .shadow(color: Color.textPrimary.opacity(0.35), radius: 4, y: 2)
                    .offset(x: geo.size.width * bmiGaugePosition - 9, y: -4)
            }
        }
        .frame(height: 18)
    }

    // MARK: - Reusable Helpers

    @ViewBuilder
    private func cardHeaderNoEdit(icon: String, title: String) -> some View {
        HStack(spacing: 9) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.brandGreenPale)
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.custom("Urbanist-SemiBold", size: 13))
                    .foregroundStyle(Color.textDark)
            }
            Text(title)
                .font(.custom("Urbanist-Bold", size: 14))
                .foregroundStyle(Color.textDark)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    @ViewBuilder
    private func cardHeader(icon: String, title: String) -> some View {
        HStack(spacing: 9) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.brandGreenPale)
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.custom("Urbanist-SemiBold", size: 13))
                    .foregroundStyle(Color.textDark)
            }
            Text(title)
                .font(.custom("Urbanist-Bold", size: 14))
                .foregroundStyle(Color.textDark)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.brandGreenPale.opacity(0.5))
                    .frame(width: 30, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.fieldBorder, lineWidth: 1)
                    )
                Image(systemName: "pencil")
                    .font(.custom("Urbanist-SemiBold", size: 12))
                    .foregroundStyle(Color.textDark)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    @ViewBuilder
    private func fieldRow<Content: View>(label: String, @ViewBuilder trailing: () -> Content) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.custom("Urbanist-Medium", size: 13))
                .foregroundStyle(Color.textMuted)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    // MARK: - Save
    private func saveChanges() {
        if let w = Double(weight) { vm.profile.weightKg = w }
        if let h = Double(height) { vm.profile.heightCm = h }
        if let b = Double(budget)  { vm.profile.dailyBudgetIDR = b }
        vm.profile.activityLevel = activity
        vm.updateProfile()
    }
}

// MARK: - Card Shell
private struct CardShell<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(spacing: 0) { content() }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.textDark.opacity(0.07), radius: 14, y: 2)
    }
}

// MARK: - Rounded Corner Shape (for hero curve)
private struct ProfileRoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}

// MARK: - Text Modifier
private extension Text {
    func unitStyle() -> some View {
        self
            .font(.custom("Urbanist-Medium", size: 12))
            .foregroundStyle(Color.textMuted)
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(UserProfileViewModel())
}

