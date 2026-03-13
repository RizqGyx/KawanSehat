import SwiftUI

// MARK: - Sleep View
struct SleepView: View {
    @EnvironmentObject var sleepVM: SleepViewModel
    @State private var showAddSleepSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Sleep Summary Card
                    VStack(spacing: 16) {
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Rata-rata Tidur (7 Hari)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(sleepVM.averageSleepFormatted)
                                    .font(.title2.bold())
                                    .foregroundColor(.blue)
                                
                                Text("Target: 7-9 jam")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 8) {
                                Text("Kualitas Rata-rata")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                HStack {
                                    ForEach(0..<4, id: \.self) { index in
                                        Image(systemName: Double(index) < sleepVM.averageQualityRating ? "star.fill" : "star")
                                            .font(.subheadline)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)
                    
                    // Gemini Advice
                    if !sleepVM.geminiAdvice.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Tips Tidur")
                                    .font(.subheadline.bold())
                                Spacer()
                                if sleepVM.isLoadingAdvice {
                                    ProgressView()
                                        .scaleEffect(0.8, anchor: .center)
                                }
                            }
                            
                            Text(sleepVM.geminiAdvice)
                                .font(.subheadline)
                                .lineLimit(nil)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                    
                    // Add Sleep Button
                    Button(action: { showAddSleepSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Tambah Tidur")
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.subheadline.bold())
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    
                    // Sleep History
                    if !sleepVM.last7DaysSleep.isEmpty {
                        VStack(spacing: 12) {
                            Text("Riwayat Tidur (7 Hari Terakhir)")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(sleepVM.last7DaysSleep, id: \.id) { log in
                                    SleepLogRow(
                                        log: log,
                                        onDelete: {
                                            sleepVM.removeSleepLog(log)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "moon.stars.fill")
                                .font(.title)
                                .foregroundColor(.blue.opacity(0.5))
                            Text("Belum ada riwayat tidur")
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
            .navigationTitle("Tidur")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddSleepSheet) {
                AddSleepSheet(sleepVM: sleepVM, isPresented: $showAddSleepSheet)
            }
            .onAppear {
                sleepVM.getGeminiAdvice()
            }
        }
    }
}

// MARK: - Sleep Log Row
struct SleepLogRow: View {
    let log: SleepLog
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(log.quality.emoji)
                        .font(.title3)
                    Text(log.quality.rawValue)
                        .font(.subheadline.bold())
                }
                
                if !log.note.isEmpty {
                    Text(log.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(log.time)
                    .font(.subheadline.bold())
                
                Text(log.dateFormatted)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red.opacity(0.6))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Add Sleep Sheet
struct AddSleepSheet: View {
    @ObservedObject var sleepVM: SleepViewModel
    @Binding var isPresented: Bool
    
    @State private var hours = "7"
    @State private var minutes = "0"
    @State private var selectedQuality = SleepQuality.good
    @State private var note = ""
    
    var durationHours: Double {
        let h = Double(hours) ?? 7
        let m = Double(minutes) ?? 0
        return h + (m / 60.0)
    }
    
    var isValid: Bool {
        (Double(hours) != nil && Double(hours)! >= 0 && Double(hours)! <= 24) &&
        (Double(minutes) != nil && Double(minutes)! >= 0 && Double(minutes)! < 60)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Durasi Tidur") {
                    HStack {
                        TextField("0", text: $hours)
                            .keyboardType(.numberPad)
                        Text("jam")
                        
                        TextField("0", text: $minutes)
                            .keyboardType(.numberPad)
                        Text("menit")
                    }
                }
                
                Section("Kualitas Tidur") {
                    Picker("Kualitas", selection: $selectedQuality) {
                        ForEach(SleepQuality.allCases, id: \.self) { quality in
                            HStack {
                                Text(quality.emoji)
                                Text(quality.rawValue)
                            }
                            .tag(quality)
                        }
                    }
                }
                
                Section("Catatan (Opsional)") {
                    TextField("Contoh: Bangun di tengah malam", text: $note)
                }
                
                Section {
                    Button(action: {
                        sleepVM.addSleepLog(
                            durationHours: durationHours,
                            quality: selectedQuality,
                            note: note
                        )
                        isPresented = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Simpan")
                                .font(.headline)
                            Spacer()
                        }
                        .foregroundColor(.blue)
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Tambah Tidur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    SleepView()
}
