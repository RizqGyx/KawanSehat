import SwiftUI

// MARK: - Validation Helpers
struct FieldError {
    var name: String? = nil
    var age: String? = nil
    var gender: String? = nil
    var weight: String? = nil
    var height: String? = nil
    var budget: String? = nil
}

func validateStep1(name: String, age: String, gender: Gender?, weight: String, height: String) -> FieldError {
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

    if gender == nil || !(gender == .male || gender == .female) {
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

            if currentStep < 3 {
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentStep
                                  ? Color.onBoardingTitle
                                  : Color.onBoardingPrimary)
                            .frame(width: index <= currentStep ? 100 : 50)
                            .frame(height: 5)
                    }
                }
                .padding(.horizontal, 20)
                .animation(.spring(), value: currentStep)
            }
        }
        .padding(.bottom, 50)
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
                VStack(alignment: .leading, spacing: 25) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Halo.")
                            .font(.custom("Urbanist-Bold", size: 55))
                            .foregroundStyle(Color.onBoardingTitle)
                        Text("Kenalan dulu yuk!")
                            .font(.custom("Urbanist-Bold", size: 32))
                            .foregroundStyle(Color.onBoardingPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    VStack(spacing: 25) {
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
                        .overlay(alignment: .trailingLastTextBaseline) {
                            Text("\(vm.formName.count)/15")
                                .font(.custom("Urbanist-Bold", size: 12))
                                .foregroundStyle(
                                    vm.formName.count >= 15
                                    ? Color(red: 0.85, green: 0.2, blue: 0.2)
                                    : Color.onBoardingPrimary.opacity(0.4)
                                )
                                .padding(.trailing, 10)
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

            OnboardingPrimaryButton(title: "Lanjut") {
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
        .onChange(of: vm.formName) {
            if vm.formName.count > 15 {
                vm.formName = String(vm.formName.prefix(15))
            }
            if didAttempt { revalidate() }
        }
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
                    .font(.custom("Urbanist-Regular", size: 12))
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
                .font(.custom("Urbanist-SemiBold", size: 16))
                .foregroundStyle(Color.onBoardingPrimary)
                .keyboardType(keyboardType)
                .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.4))

            if let label = trailingLabel {
                Text(label)
                    .font(.custom("Urbanist-Regular", size: 14))
                    .foregroundStyle(Color.onBoardingPrimary.opacity(0.5))
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

                Text(isUnselected ? "Gender" : vm.formGender?.rawValue ?? "Gender")
                    .font(.custom("Urbanist-SemiBold", size: 16))
                    .foregroundStyle(
                        isUnselected
                        ? Color.onBoardingPrimary.opacity(0.3)
                        : Color.onBoardingPrimary.opacity(1.0)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text("L / P")
                .font(.custom("Urbanist-Regular", size: 14))
                .foregroundStyle(Color.onBoardingPrimary.opacity(0.5))
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
                .font(.custom("Urbanist-ExtraBold", size: 32))
                .foregroundStyle(Color.onBoardingPrimary)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)

            Image(activityLevels[currentIndex].imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.25), value: currentIndex)

            VStack(spacing: 4) {
                Text(activityLevels[currentIndex].name)
                    .font(.custom("Urbanist-SemiBold", size: 24))
                    .foregroundStyle(Color.onBoardingPrimary)
                Text(activityLevels[currentIndex].description)
                    .font(Font.custom("Urbanist-SemiBold", size: 16))
                    .foregroundStyle(Color.onBoardingPrimary.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .padding(.bottom, 16)

            HStack() {
                Image(systemName: "zzz")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.onBoardingPrimary.opacity(0.5))
                Slider(value: $activityIndex, in: 0...4, step: 1)
                    .tint(Color.onBoardingTitle)
                    .onChange(of: activityIndex) { _, newValue in
                        vm.formActivity = activityLevels[Int(newValue)].level
                    }
                    .padding(.horizontal, 4)
                Image(systemName: "figure.run")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.onBoardingPrimary.opacity(0.5))
            }
            .padding(.bottom, 8)
            .padding(.horizontal, 24)

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
                    .font(.custom("Urbanist-ExtraBold", size: 64))
                    .foregroundStyle(Color.onBoardingTitle)
                Text("Budget makan\nharian kamu?")
                    .font(.custom("Urbanist-ExtraBold", size: 32))
                    .foregroundStyle(Color.onBoardingPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 28)

            ValidatedField(errorMessage: errors.budget) {
                HStack {
                    Text("Rp")
                        .font(.custom("Urbanist-SemiBold", size: 16))
                        .foregroundStyle(Color.onBoardingPrimary.opacity(0.5))
                    TextField("Budget Harian", text: $vm.formBudget)
                        .font(.custom("Urbanist-SemiBold", size: 16))
                        .foregroundStyle(Color.onBoardingPrimary)
                        .keyboardType(.numberPad)
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
                Text("Yay, \(vm.formName)!")
                    .font(.custom("Urbanist-ExtraBold", size: 64))
                    .foregroundStyle(Color.onBoardingTitle)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .truncationMode(.tail)
                Text("Perjalanan sehatmu\ndimulai sekarang!")
                    .font(.custom("Urbanist-ExtraBold", size: 32))
                    .foregroundStyle(Color.onBoardingPrimary)
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
            HStack(spacing: 0) {
                Text(title.replacingOccurrences(of: " →", with: ""))
                    .font(.custom("Urbanist-Bold", size: 24))
                Text(" →")
                    .font(.custom("Urbanist-Bold", size: 24))
                    .baselineOffset(-3)
            }
            .foregroundStyle(Color.onBoardingWhite)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.onBoardingTitle)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView().environmentObject(UserProfileViewModel())
}

