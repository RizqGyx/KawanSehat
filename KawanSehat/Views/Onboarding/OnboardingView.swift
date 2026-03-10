import SwiftUI

// MARK: - OnboardingView
/// Feature 3: Health Data Input form shown on first launch
struct OnboardingView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @State private var currentStep: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentStep + 1), total: 3)
                    .tint(.green)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Step label
                Text("Langkah \(currentStep + 1) dari 3")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                
                // Step content
                TabView(selection: $currentStep) {
                    OnboardingStep1View(currentStep: $currentStep)
                        .tag(0)
                    OnboardingStep2View(currentStep: $currentStep)
                        .tag(1)
                    OnboardingStep3View()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
            .navigationTitle("Selamat Datang! 👋")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Step 1: Personal Info
struct OnboardingStep1View: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Binding var currentStep: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Isi data pribadimu")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                // Name field
                VStack(alignment: .leading, spacing: 6) {
                    Label("Nama", systemImage: "person.fill")
                        .font(.subheadline.bold())
                    TextField("Nama kamu", text: $vm.formName)
                        .textFieldStyle(.roundedBorder)
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
                        Text("tahun")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
                
                // Next button
                Button {
                    withAnimation { currentStep = 1 }
                } label: {
                    Label("Lanjut", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.formName.isEmpty ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(vm.formName.isEmpty)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Step 2: Body Measurements
struct OnboardingStep2View: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Binding var currentStep: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Ukuran tubuhmu")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                // Weight
                VStack(alignment: .leading, spacing: 6) {
                    Label("Berat Badan", systemImage: "scalemass.fill")
                        .font(.subheadline.bold())
                    HStack {
                        TextField("65", text: $vm.formWeight)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Height
                VStack(alignment: .leading, spacing: 6) {
                    Label("Tinggi Badan", systemImage: "ruler.fill")
                        .font(.subheadline.bold())
                    HStack {
                        TextField("165", text: $vm.formHeight)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        Text("cm")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Activity level
                VStack(alignment: .leading, spacing: 6) {
                    Label("Tingkat Aktivitas", systemImage: "figure.run")
                        .font(.subheadline.bold())
                    Picker("Aktivitas", selection: $vm.formActivity) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.description).tag(level)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .clipped()
                }
                .padding(.horizontal)
                
                HStack {
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
                            .background(Color.green)
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

// MARK: - Step 3: Budget + Finish
struct OnboardingStep3View: View {
    @EnvironmentObject var vm: UserProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Budget harianmu")
                    .font(.title2.bold())
                    .padding(.horizontal)
                
                // Daily budget input
                VStack(alignment: .leading, spacing: 6) {
                    Label("Budget Makan Harian", systemImage: "creditcard.fill")
                        .font(.subheadline.bold())
                    HStack {
                        Text("Rp")
                            .foregroundStyle(.secondary)
                            .padding(.leading, 8)
                        TextField("50000", text: $vm.formBudget)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                    }
                    Text("Budget per makan: Rp\(Int((Double(vm.formBudget) ?? 50000) / 3))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // Budget presets
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pilihan cepat:")
                        .font(.subheadline.bold())
                    HStack(spacing: 8) {
                        ForEach(["20.000", "35.000", "50.000", "75.000"], id: \.self) { preset in
                            Button("Rp\(preset)") {
                                vm.formBudget = preset.replacingOccurrences(of: ".", with: "")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
                
                // Summary card preview
                if vm.isFormValid {
                    OnboardingSummaryCard(vm: vm)
                        .padding(.horizontal)
                }
                
                // Validation error
                if vm.showValidationError {
                    Text(vm.validationMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Spacer(minLength: 40)
                
                // Save & Start button
                Button {
                    vm.saveProfile()
                } label: {
                    Label("Mulai Sekarang! 🚀", systemImage: "checkmark.circle.fill")
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

// MARK: - Onboarding Summary Preview Card
struct OnboardingSummaryCard: View {
    let vm: UserProfileViewModel
    
    // Compute preview BMI from form values
    var previewBMI: Double {
        let weight = Double(vm.formWeight) ?? 65
        let height = (Double(vm.formHeight) ?? 165) / 100
        return weight / (height * height)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ringkasan")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("BMI Estimasi")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f", previewBMI))
                        .font(.title2.bold())
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Budget / Makan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Rp\(Int((Double(vm.formBudget) ?? 50000) / 3))")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
