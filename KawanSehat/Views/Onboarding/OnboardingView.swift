import SwiftUI

// MARK: - OnboardingView (4 Steps)
struct OnboardingView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @State private var currentStep: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator (4 steps)
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .transition(.scale)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Step label
                HStack {
                    Text("Langkah \(currentStep + 1) dari 4")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Step content
                TabView(selection: $currentStep) {
                    OnboardingStep1View(currentStep: $currentStep)
                        .tag(0)
                    OnboardingStep2View(currentStep: $currentStep)
                        .tag(1)
                    OnboardingStep3View(currentStep: $currentStep)
                        .tag(2)
                    OnboardingStep4SummaryView()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
            .navigationTitle("Selamat Datang! 👋")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Step 1: Personal Data
struct OnboardingStep1View: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Binding var currentStep: Int
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, age, height, weight
    }
    
    var isValid: Bool {
        !vm.formName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(vm.formAge) != nil && Int(vm.formAge)! > 0 &&
        Double(vm.formHeight) != nil && Double(vm.formHeight)! > 0 &&
        Double(vm.formWeight) != nil && Double(vm.formWeight)! > 0
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Kenalan dulu, yuk!")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                // Name field
                VStack(alignment: .leading, spacing: 6) {
                    Label("Nama Lengkap", systemImage: "person.fill")
                        .font(.subheadline.bold())
                    TextField("Nama kamu", text: $vm.formName)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .name)
                }
                .padding(.horizontal)
                
                // Gender picker
                VStack(alignment: .leading, spacing: 6) {
                    Label("Jenis Kelamin", systemImage: "figure.dress.line.vertical.figure")
                        .font(.subheadline.bold())
                    Picker("Jenis Kelamin", selection: $vm.formGender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                
                // Age field
                VStack(alignment: .leading, spacing: 6) {
                    Label("Usia", systemImage: "calendar")
                        .font(.subheadline.bold())
                    HStack {
                        TextField("25", text: $vm.formAge)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .age)
                        Text("tahun")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Height field
                VStack(alignment: .leading, spacing: 6) {
                    Label("Tinggi Badan", systemImage: "ruler.fill")
                        .font(.subheadline.bold())
                    HStack {
                        TextField("165", text: $vm.formHeight)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .height)
                        Text("cm")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Weight field
                VStack(alignment: .leading, spacing: 6) {
                    Label("Berat Badan", systemImage: "scalemass.fill")
                        .font(.subheadline.bold())
                    HStack {
                        TextField("65", text: $vm.formWeight)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .weight)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
                
                // Next button
                Button {
                    focusedField = nil
                    withAnimation { currentStep = 1 }
                } label: {
                    Label("Lanjut", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isValid)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Step 2: Activity Level (Card Selection)
struct OnboardingStep2View: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Binding var currentStep: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Seberapa aktif kamu?")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                Text("Pilih opsi yang paling sesuai dengan gaya hidup kamu")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        ActivityLevelCard(
                            level: level,
                            isSelected: vm.formActivity == level,
                            onSelect: { vm.formActivity = level }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
                
                HStack(spacing: 12) {
                    Button {
                        withAnimation { currentStep = 0 }
                    } label: {
                        Label("Kembali", systemImage: "arrow.left")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        withAnimation { currentStep = 2 }
                    } label: {
                        Label("Lanjut", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Activity Level Card Component
struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let onSelect: () -> Void
    
    var icon: String {
        switch level {
        case .sedentary:   return "figure.seated"
        case .light:       return "figure.walk"
        case .moderate:    return "figure.stairs"
        case .active:      return "figure.run"
        case .veryActive:  return "figure.indoor.cycle"
        }
    }
    
    var detailedDescription: String {
        switch level {
        case .sedentary:
            return "Jarang olahraga, kerja duduk terus"
        case .light:
            return "Olahraga ringan 1–3x seminggu"
        case .moderate:
            return "Olahraga sedang 3–5x seminggu"
        case .active:
            return "Olahraga berat 6–7x seminggu"
        case .veryActive:
            return "Atlet atau kerja fisik berat"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.rawValue)
                        .font(.subheadline.bold())
                    Text(detailedDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            withAnimation {
                onSelect()
            }
        }
    }
}

// MARK: - Step 3: Budget Setup
struct OnboardingStep3View: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Binding var currentStep: Int
    @FocusState private var focusedField: Field?
    
    enum Field {
        case dailyBudget, monthlyBudget
    }
    
    var isValid: Bool {
        Double(vm.formBudget) != nil && Double(vm.formBudget)! > 0 &&
        Double(vm.formMonthlyBudget) != nil && Double(vm.formMonthlyBudget)! > 0
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Atur budget sehatmu")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                // Budget explanation
                VStack(alignment: .leading, spacing: 8) {
                    Label("Budget Harian", systemImage: "creditcard")
                        .font(.subheadline.bold())
                    Text("Budget untuk makanan & kesehatan per hari")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // Daily budget input
                HStack {
                    Text("Rp")
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                    TextField("50000", text: $vm.formBudget)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .dailyBudget)
                }
                .padding(.horizontal)
                
                // Budget presets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pilihan cepat:")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach(["30000", "50000", "75000", "100000"], id: \.self) { preset in
                            Button("Rp\(preset)") {
                                vm.formBudget = preset
                            }
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Monthly budget
                VStack(alignment: .leading, spacing: 8) {
                    Label("Budget Bulanan", systemImage: "calendar")
                        .font(.subheadline.bold())
                    Text("Budget kesehatan & investasi kesehatan bulanan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Rp")
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                    TextField("1500000", text: $vm.formMonthlyBudget)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .monthlyBudget)
                }
                .padding(.horizontal)
                
                // Dietary preference
                VStack(alignment: .leading, spacing: 6) {
                    Label("Preferensi Diet", systemImage: "fork.knife")
                        .font(.subheadline.bold())
                    Picker("Preferensi", selection: $vm.formDietaryPreference) {
                        ForEach(DietaryPreference.allCases, id: \.self) { pref in
                            Text(pref.rawValue).tag(pref)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
                
                HStack(spacing: 12) {
                    Button {
                        focusedField = nil
                        withAnimation { currentStep = 1 }
                    } label: {
                        Label("Kembali", systemImage: "arrow.left")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        focusedField = nil
                        withAnimation { currentStep = 3 }
                    } label: {
                        Label("Lanjut", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!isValid)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Step 4: Results Summary
struct OnboardingStep4SummaryView: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    // Compute values from form
    var weight: Double { Double(vm.formWeight) ?? 65 }
    var height: Double { Double(vm.formHeight) ?? 165 }
    var age: Int { Int(vm.formAge) ?? 25 }
    
    var bmi: Double {
        let heightM = height / 100.0
        return weight / (heightM * heightM)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Kurus (Underweight)"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Gemuk (Overweight)"
        default: return "Obesitas"
        }
    }
    
    var bmiColor: Color {
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    var bmr: Double {
        switch vm.formGender {
        case .male:
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        case .female:
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }
    
    var tdee: Double {
        return bmr * vm.formActivity.multiplier
    }
    
    var proteinG: Double {
        (tdee * 0.25) / 4.0
    }
    
    var carbsG: Double {
        (tdee * 0.50) / 4.0
    }
    
    var fatG: Double {
        (tdee * 0.25) / 9.0
    }
    
    var waterL: Double {
        (weight * 33.0) / 1000.0
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Ini profil kesehatanmu! 🎉")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                // BMI Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("BMI")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.1f", bmi))
                                .font(.title.bold())
                                .foregroundColor(bmiColor)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(bmiCategory)
                                .font(.subheadline)
                                .foregroundColor(bmiColor)
                            ProgressView(value: min(bmi / 40, 1.0))
                                .tint(bmiColor)
                                .frame(width: 100)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4)
                .padding(.horizontal)
                
                // TDEE Card
                VStack(spacing: 8) {
                    Text("Kebutuhan Kalori Harian (TDEE)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    HStack(spacing: 0) {
                        Text(String(format: "%.0f", tdee))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("kkal")
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 4)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 4)
                .padding(.horizontal)
                
                // Macros Pills
                VStack(spacing: 8) {
                    Text("Target Makronutrien Harian")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        MacroPill(
                            label: "Protein",
                            value: String(format: "%.0f", proteinG),
                            unit: "g",
                            color: .red
                        )
                        MacroPill(
                            label: "Karbo",
                            value: String(format: "%.0f", carbsG),
                            unit: "g",
                            color: .blue
                        )
                        MacroPill(
                            label: "Lemak",
                            value: String(format: "%.0f", fatG),
                            unit: "g",
                            color: .yellow
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Water Goal
                VStack(spacing: 8) {
                    HStack {
                        Label("Target Air Minum", systemImage: "drop.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "drop.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading) {
                            Text(String(format: "%.1f liter/hari", waterL))
                                .font(.headline)
                            Text("Minum secara merata sepanjang hari")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                // Budget summary
                VStack(spacing: 8) {
                    HStack {
                        Label("Budget Harianmu", systemImage: "creditcard")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "creditcard.fill")
                            .font(.title)
                            .foregroundColor(.green)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading) {
                            Text("Rp \(Int(Double(vm.formBudget) ?? 50000))")
                                .font(.headline)
                            Text("per hari")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
                
                // Start button
                Button {
                    vm.saveProfile()
                } label: {
                    Label("Mulai HealthQuest! 🚀", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .font(.headline)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Macro Pill Component
struct MacroPill: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            HStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
