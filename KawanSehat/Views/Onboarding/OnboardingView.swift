import SwiftUI

// MARK: - Color Extension
extension Color {
    static let appBackground = Color(red: 0.984, green: 0.98, blue: 0.96)
    static let fieldBackground = Color(red: 0.941, green: 0.957, blue: 0.937)
    static let fieldBorder = Color(red: 0.847, green: 0.91, blue: 0.831)
    static let fieldError = Color(red: 1.0, green: 0.92, blue: 0.92)
    static let fieldBorderError = Color(red: 0.9, green: 0.3, blue: 0.3)

    static let textDark = Color(red: 0.102, green: 0.169, blue: 0.114)
    static let textPrimary = Color(red: 0.176, green: 0.235, blue: 0.188)
    static let textMid = Color(red: 0.29, green: 0.376, blue: 0.314)
    static let textMuted = Color(red: 0.478, green: 0.58, blue: 0.502)

    static let brandGreenPale = Color(red: 0.929, green: 0.965, blue: 0.902)
    static let brandGreenLight = Color(red: 0.839, green: 0.941, blue: 0.769)
    static let brandGreenPrimary = Color(red: 0.714, green: 0.882, blue: 0.612)
    static let brandGreenDark = Color(red: 0.49, green: 0.776, blue: 0.388)
    static let brandGreenButton = Color(red: 0.306, green: 0.6, blue: 0.22)

    static let onBoardingTitle = Color(red: 0.39, green: 0.78, blue: 0.34)
    static let onBoardingPrimary = Color(red: 0.157, green: 0.231, blue: 0.173)
}

// MARK: - Validation Helpers
struct FieldError {
    var name: String? = nil
    var age: String? = nil
    var gender: String? = nil
    var weight: String? = nil
    var height: String? = nil
    var budget: String? = nil
}

func validateStep1(name: String, age: String, gender: Gender, weight: String, height: String) -> FieldError {
    var errors = FieldError()

    if name.trimmingCharacters(in: .whitespaces).isEmpty {
        errors.name = "Nama panggilan tidak boleh kosong"
    }

    if age.trimmingCharacters(in: .whitespaces).isEmpty {
        errors.age = "Usia tidak boleh kosong"
    } else if let ageVal = Int(age), ageVal < 1 || ageVal > 120 {
        errors.age = "Usia harus antara 1–120"
    } else if Int(age) == nil {
        errors.age = "Usia harus berupa angka"
    }

    if !(gender == .male || gender == .female) {
        errors.gender = "Pilih gender"
    }

    if weight.trimmingCharacters(in: .whitespaces).isEmpty {
        errors.weight = "Berat tidak boleh kosong"
    } else if let w = Double(weight), w < 1 || w > 300 {
        errors.weight = "Berat harus antara 1–300 kg"
    } else if Double(weight) == nil {
        errors.weight = "Berat harus berupa angka"
    }

    if height.trimmingCharacters(in: .whitespaces).isEmpty {
        errors.height = "Tinggi tidak boleh kosong"
    } else if let h = Double(height), h < 50 || h > 250 {
        errors.height = "Tinggi harus antara 50–250 cm"
    } else if Double(height) == nil {
        errors.height = "Tinggi harus berupa angka"
    }

    return errors
}

func validateStep3(budget: String) -> FieldError {
    var errors = FieldError()

    if budget.trimmingCharacters(in: .whitespaces).isEmpty {
        errors.budget = "Budget tidak boleh kosong"
    } else if let b = Double(budget), b < 1000 {
        errors.budget = "Budget minimal Rp 1.000"
    } else if Double(budget) == nil {
        errors.budget = "Budget harus berupa angka"
    }

    return errors
}

// MARK: - OnboardingView
struct OnboardingView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @State private var currentStep: Int = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                OnboardingHeaderView(currentStep: currentStep)
                TabView(selection: $currentStep) {
                    OnboardingStep1View(currentStep: $currentStep).tag(0)
                    OnboardingStep2View(currentStep: $currentStep).tag(1)
                    OnboardingStep3View(currentStep: $currentStep).tag(2)
                    OnboardingStep4View().tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

// MARK: - Header
struct OnboardingHeaderView: View {
    let currentStep: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 39, height: 39)
                Text("KawanSehat")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep
                              ? Color.brandGreenButton
                              : Color.brandGreenButton.opacity(0.5))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 20)
            .animation(.spring(), value: currentStep)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Step 1: Personal Info
struct OnboardingStep1View: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Binding var currentStep: Int
    @State private var errors = FieldError()
    @State private var didAttempt = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Halo.")
                            .font(.system(size: 55, weight: .bold))
                            .foregroundStyle(Color.onBoardingTitle)
                        Text("Kenalan dulu yuk!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.onBoardingPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    VStack(spacing: 12) {
                        // Nama
                        ValidatedField(errorMessage: errors.name) {
                            InlineTextField(
                                placeholder: "Nama Panggilan",
                                text: $vm.formName,
                                trailingLabel: nil,
                                keyboardType: .default,
                                hasError: errors.name != nil
                            )
                        }

                        // Usia & Gender
                        HStack(spacing: 12) {
                            ValidatedField(errorMessage: errors.age) {
                                InlineTextField(
                                    placeholder: "Usia",
                                    text: $vm.formAge,
                                    trailingLabel: "Tahun",
                                    keyboardType: .numberPad,
                                    hasError: errors.age != nil
                                )
                            }
                            ValidatedField(errorMessage: errors.gender) {
                                InlineGenderField(vm: vm, hasError: errors.gender != nil)
                            }
                        }

                        // Berat & Tinggi
                        HStack(spacing: 12) {
                            ValidatedField(errorMessage: errors.weight) {
                                InlineTextField(
                                    placeholder: "Berat",
                                    text: $vm.formWeight,
                                    trailingLabel: "Kg",
                                    keyboardType: .decimalPad,
                                    hasError: errors.weight != nil
                                )
                            }
                            ValidatedField(errorMessage: errors.height) {
                                InlineTextField(
                                    placeholder: "Tinggi",
                                    text: $vm.formHeight,
                                    trailingLabel: "cm",
                                    keyboardType: .decimalPad,
                                    hasError: errors.height != nil
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)
            }

            OnboardingPrimaryButton(title: "Lanjut →") {
                didAttempt = true
                errors = validateStep1(
                    name: vm.formName,
                    age: vm.formAge,
                    gender: vm.formGender,
                    weight: vm.formWeight,
                    height: vm.formHeight
                )
                let isValid = errors.name == nil &&
                              errors.age == nil &&
                              errors.gender == nil &&
                              errors.weight == nil &&
                              errors.height == nil
                if isValid {
                    withAnimation { currentStep = 1 }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        // Re-validasi live setelah user pernah tekan Lanjut
        .onChange(of: vm.formName)   { if didAttempt { revalidate() } }
        .onChange(of: vm.formAge)    { if didAttempt { revalidate() } }
        .onChange(of: vm.formGender) { if didAttempt { revalidate() } }
        .onChange(of: vm.formWeight) { if didAttempt { revalidate() } }
        .onChange(of: vm.formHeight) { if didAttempt { revalidate() } }
    }

    private func revalidate() {
        errors = validateStep1(
            name: vm.formName,
            age: vm.formAge,
            gender: vm.formGender,
            weight: vm.formWeight,
            height: vm.formHeight
        )
    }
}

// MARK: - Validated Field Wrapper
struct ValidatedField<Content: View>: View {
    let errorMessage: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
            if let msg = errorMessage {
                Text(msg)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color(red: 0.85, green: 0.2, blue: 0.2))
                    .padding(.horizontal, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }
}

// MARK: - Inline Text Field
struct InlineTextField: View {
    let placeholder: String
    @Binding var text: String
    let trailingLabel: String?
    let keyboardType: UIKeyboardType
    var hasError: Bool = false

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .font(.system(size: 15, weight: .regular))
                .keyboardType(keyboardType)
                .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))

            if let label = trailingLabel {
                Text(label)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.65))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background(hasError ? Color.fieldError : Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(hasError ? Color.fieldBorderError : Color.clear, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: hasError)
    }
}

// MARK: - Inline Gender Field
struct InlineGenderField: View {
    @ObservedObject var vm: UserProfileViewModel
    var hasError: Bool = false

    var body: some View {
        HStack {
            Menu {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button(action: { vm.formGender = gender }) {
                        Text(gender.rawValue)
                    }
                }
            } label: {
                let isSelectedMale = vm.formGender == .male
                let isSelectedFemale = vm.formGender == .female
                let isUnselected = !(isSelectedMale || isSelectedFemale)

                Text(isUnselected ? "Gender" : vm.formGender.rawValue)
                    .font(.system(size: 15))
                    .foregroundStyle(
                        isUnselected
                        ? Color(red: 0.6, green: 0.6, blue: 0.6)
                        : Color(red: 0.4, green: 0.4, blue: 0.4)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if vm.formGender == .male || vm.formGender == .female {
                Text(vm.formGender == .male ? "L" : "P")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.65, green: 0.65, blue: 0.65))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .background(hasError ? Color.fieldError : Color.fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(hasError ? Color.fieldBorderError : Color.clear, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: hasError)
    }
}

// MARK: - Step 2: Activity Level (tidak ada validasi — slider selalu punya nilai)
struct OnboardingStep2View: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Binding var currentStep: Int
    @State private var activityIndex: Double = 0

    let activityLevels: [(name: String, description: String, imageName: String, level: ActivityLevel)] = [
        ("Tidak Aktif",   "Hampir tidak pernah bergerak aktif",   "Sedentary",   .sedentary),
        ("Sedikit Aktif", "Olahraga ringan 1–3 kali seminggu",    "Lightly",     .light),
        ("Cukup Aktif",   "Olahraga ringan 3–5 kali seminggu",    "Moderately",  .moderate),
        ("Sangat Aktif",  "Olahraga intens 6–7 kali seminggu",    "Very",        .active),
        ("Ekstra Aktif",  "Olahraga berat dua kali sehari",       "Extra",       .veryActive),
    ]

    var currentIndex: Int { min(Int(activityIndex), activityLevels.count - 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Seberapa sering kamu\nolahraga?")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color(red: 0.078, green: 0.173, blue: 0.110))
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)

            Image(activityLevels[currentIndex].imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.25), value: currentIndex)

            VStack(spacing: 4) {
                Text(activityLevels[currentIndex].name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 0.078, green: 0.173, blue: 0.110))
                Text(activityLevels[currentIndex].description)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.55))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .padding(.bottom, 16)

            VStack(spacing: 6) {
                Slider(value: $activityIndex, in: 0...4, step: 1)
                    .tint(Color.brandGreenButton)
                    .onChange(of: activityIndex) { _, newValue in
                        vm.formActivity = activityLevels[Int(newValue)].level
                    }
                    .padding(.horizontal, 20)

                HStack {
                    Text("Zzz")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.55))
                    Spacer()
                    Image(systemName: "figure.run")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.55))
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 8)

            Spacer()

            OnboardingPrimaryButton(title: "Lanjut →") {
                withAnimation { currentStep = 2 }
            }
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Step 3: Budget
struct OnboardingStep3View: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Binding var currentStep: Int
    @State private var errors = FieldError()
    @State private var didAttempt = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Berapa sih")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(Color.brandGreenLight)
                Text("Budget makan\nharian kamu?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Color(red: 0.078, green: 0.173, blue: 0.110))
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 28)

            ValidatedField(errorMessage: errors.budget) {
                HStack {
                    Text("Rp")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                    TextField("Budget Harian", text: $vm.formBudget)
                        .font(.system(size: 16))
                        .keyboardType(.numberPad)
                        .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 18)
                .background(errors.budget != nil ? Color.fieldError : Color.fieldBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(errors.budget != nil ? Color.fieldBorderError : Color.clear, lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.2), value: errors.budget)
            }
            .padding(.horizontal, 20)

            Spacer()

            OnboardingPrimaryButton(title: "Lanjut →") {
                didAttempt = true
                errors = validateStep3(budget: vm.formBudget)
                if errors.budget == nil {
                    withAnimation { currentStep = 3 }
                }
            }
            .padding(.bottom, 32)
        }
        .onChange(of: vm.formBudget) {
            if didAttempt { errors = validateStep3(budget: vm.formBudget) }
        }
    }
}

// MARK: - Step 4: Finish
struct OnboardingStep4View: View {
    @EnvironmentObject var vm: UserProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("PartyPopper")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Spacer().frame(height: 32)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 0) {
                    Text("Yay, ")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.brandGreenLight)
                    Text("\(vm.formName)!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.brandGreenLight)
                }
                Text("Perjalanan sehatmu\ndimulai sekarang!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(red: 0.078, green: 0.173, blue: 0.110))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Spacer()

            OnboardingPrimaryButton(title: "Mulai") {
                vm.saveProfile()
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Reusable Primary Button
struct OnboardingPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.brandGreenButton)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
    }
}

