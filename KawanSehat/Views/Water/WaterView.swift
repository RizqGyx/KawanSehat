import SwiftUI

// MARK: - WaterView
struct WaterView: View {
    @EnvironmentObject var waterVM: WaterViewModel
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Circular Progress
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                            
                            Circle()
                                .trim(from: 0, to: waterVM.percentageComplete)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .blue.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: waterVM.percentageComplete)
                            
                            VStack(spacing: 8) {
                                Text(waterVM.todayTotalFormatted)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.blue)
                                Text("dari \(String(format: "%.1f", waterVM.dailyGoal / 1000.0)) L")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(height: 240)
                        .padding()
                        
                        // Motivational message
                        Text(waterVM.motivationalMessage)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)
                    
                    // Quick add buttons
                    VStack(spacing: 12) {
                        Text("Tambah Air")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            QuickAddButton(amount: 150, label: "+150ml") {
                                waterVM.addWater(amount: 150)
                            }
                            
                            QuickAddButton(amount: 250, label: "+250ml") {
                                waterVM.addWater(amount: 250)
                            }
                            
                            QuickAddButton(amount: 330, label: "+330ml") {
                                waterVM.addWater(amount: 330)
                            }
                            
                            QuickAddButton(amount: 500, label: "+500ml") {
                                waterVM.addWater(amount: 500)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Custom add section
                    VStack(spacing: 12) {
                        Label("Tambah Kustom", systemImage: "plus.circle.fill")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: CustomWaterAddView(waterVM: waterVM)) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                Text("Masukkan jumlah custom")
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                    }
                    
                    // Today's logs
                    if !waterVM.todayLogs.isEmpty {
                        VStack(spacing: 12) {
                            Label("Riwayat Hari Ini", systemImage: "clock.fill")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(waterVM.todayLogs, id: \.id) { log in
                                    HStack {
                                        Image(systemName: "drop.fill")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(log.amountFormatted)
                                                .font(.subheadline.bold())
                                            Text(log.dateFormatted)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: { waterVM.removeLog(log) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red.opacity(0.6))
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "drop.fill")
                                .font(.title)
                                .foregroundColor(.blue.opacity(0.5))
                            Text("Belum ada riwayat hari ini")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .navigationTitle("Air Minum")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                waterVM.updateProfile(userProfileVM.profile)
            }
        }
    }
}

// MARK: - Quick Add Button
struct QuickAddButton: View {
    let amount: Double
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                Text(label)
                    .font(.caption2.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Custom Water Add View
struct CustomWaterAddView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var waterVM: WaterViewModel
    @State private var customAmount = ""
    @State private var selectedUnit = "ml"
    
    let units = ["ml", "L"]
    
    var isValid: Bool {
        Double(customAmount) != nil && Double(customAmount)! > 0
    }
    
    var body: some View {
        Form {
            Section("Jumlah Air") {
                HStack {
                    TextField("Masukkan jumlah", text: $customAmount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Unit", selection: $selectedUnit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)
                }
            }
            
            Section {
                Button(action: {
                    if let amount = Double(customAmount) {
                        let mlAmount = selectedUnit == "ml" ? amount : amount * 1000
                        waterVM.addWater(amount: mlAmount)
                        dismiss()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Tambah")
                            .font(.headline)
                        Spacer()
                    }
                    .foregroundColor(.blue)
                }
                .disabled(!isValid)
            }
        }
        .navigationTitle("Tambah Air Minum")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    WaterView()
        .environmentObject(WaterViewModel(userProfile: UserProfile()))
        .environmentObject(UserProfileViewModel())
}
