import SwiftUI

// MARK: - ProfileView
/// Allows user to update their health profile after onboarding
struct ProfileView: View {
    @EnvironmentObject var vm: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field {
        case weight
        case height
        case budget
    }
    
    // Local state for editing
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var budget: String = ""
    @State private var activity: ActivityLevel = .moderate
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                Form {
                    Section("Data Tubuh") {
                        HStack {
                            Text("Berat")
                            Spacer()
                            TextField("kg", text: $weight)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .focused($focusedField, equals: .weight)
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Tinggi")
                            Spacer()
                            TextField("cm", text: $height)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .focused($focusedField, equals: .height)
                            Text("cm")
                                .foregroundStyle(.secondary)
                        }
                        
                        Picker("Aktivitas", selection: $activity) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                    }
                    
                    Section("Budget Harian") {
                        HStack {
                            Text("Rp")
                                .foregroundStyle(.secondary)
                            TextField("50000", text: $budget)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .budget)
                        }
                    }
                    
                    if let w = Double(weight), let h = Double(height), h > 0 {
                        Section("Kalkulasi") {
                            let bmi = w / ((h/100) * (h/100))
                            HStack {
                                Text("BMI")
                                Spacer()
                                Text(String(format: "%.1f", bmi))
                                    .bold()
                                    .foregroundColor(bmi < 18.5 ? .blue : bmi < 25 ? .green : bmi < 30 ? .orange : .red)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden) // ← Wajib! Sembunyikan background default Form
            }
            .navigationTitle("Edit Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") {
                        focusedField = nil
                        saveChanges()
                        dismiss()
                    }
                    .bold()
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .onAppear {
                weight = String(vm.profile.weightKg)
                height = String(vm.profile.heightCm)
                budget = String(Int(vm.profile.dailyBudgetIDR))
                activity = vm.profile.activityLevel
            }
        }
    }
    
    private func saveChanges() {
        if let w = Double(weight) { vm.profile.weightKg = w }
        if let h = Double(height) { vm.profile.heightCm = h }
        if let b = Double(budget) { vm.profile.dailyBudgetIDR = b }
        vm.profile.activityLevel = activity
        vm.updateProfile()
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(UserProfileViewModel())
}
