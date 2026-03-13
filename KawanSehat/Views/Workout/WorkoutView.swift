import SwiftUI

// MARK: - Workout View
struct WorkoutView: View {
    @EnvironmentObject var workoutVM: WorkoutViewModel
    @State private var showAddWorkoutSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Status Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Status Olahraga Hari Ini")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 8) {
                                    Image(systemName: workoutVM.hasWorkoutToday ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(workoutVM.hasWorkoutToday ? .green : .gray)
                                    Text(workoutVM.hasWorkoutToday ? "Sudah" : "Belum")
                                        .font(.headline)
                                        .foregroundColor(workoutVM.hasWorkoutToday ? .green : .gray)
                                }
                            }
                            
                            Spacer()
                            
                            if workoutVM.hasWorkoutToday {
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Kalori Terbakar")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(workoutVM.todayCaloriesBurned)")
                                        .font(.title3.bold())
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)
                    
                    // Weekly Summary
                    VStack(spacing: 12) {
                        HStack {
                            Label("Minggu Ini", systemImage: "calendar")
                                .font(.subheadline.bold())
                            Spacer()
                            Text("\(workoutVM.thisWeekCount) workout")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            InfoBubble(label: "Workout", value: String(workoutVM.thisWeekCount), color: .blue)
                            InfoBubble(label: "Kalori", value: String(workoutVM.thisWeekCaloriesBurned), color: .orange)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.05), radius: 4)
                    .padding(.horizontal)
                    
                    // Add Workout Button
                    Button(action: { showAddWorkoutSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Tambah Olahraga")
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
                    
                    // This Week's Workouts
                    if !workoutVM.thisWeekWorkouts.isEmpty {
                        VStack(spacing: 12) {
                            Text("Riwayat Minggu Ini")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(workoutVM.thisWeekWorkouts, id: \.id) { log in
                                    WorkoutLogRow(
                                        log: log,
                                        onDelete: {
                                            workoutVM.removeWorkout(log)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "dumbbell.fill")
                                .font(.title)
                                .foregroundColor(.blue.opacity(0.5))
                            Text("Belum ada olahraga minggu ini")
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
            .navigationTitle("Olahraga")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddWorkoutSheet) {
                AddWorkoutSheet(workoutVM: workoutVM, isPresented: $showAddWorkoutSheet)
            }
        }
    }
}

// MARK: - Info Bubble
struct InfoBubble: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.headline.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Workout Log Row
struct WorkoutLogRow: View {
    let log: WorkoutLog
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(log.intensityEmoji)
                    Text(log.exerciseName)
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
                HStack(spacing: 8) {
                    Label(String(log.durationMinutes), systemImage: "clock")
                        .font(.caption)
                    Label(String(log.caloriesBurned), systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Text(log.timeFormatted)
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

// MARK: - Add Workout Sheet
struct AddWorkoutSheet: View {
    @ObservedObject var workoutVM: WorkoutViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedExercise = "Berlari"
    @State private var durationMinutes = "30"
    @State private var selectedIntensity = "Sedang"
    @State private var note = ""
    @State private var customExercise = ""
    
    let intensities = ["Ringan", "Sedang", "Berat"]
    
    var exercises: [String] {
        var list = WorkoutViewModel.commonExercises
        if !customExercise.isEmpty && !list.contains(customExercise) {
            list.insert(customExercise, at: 0)
        }
        return list
    }
    
    var estimatedCalories: Int {
        let exercise = customExercise.isEmpty ? selectedExercise : customExercise
        let duration = Int(durationMinutes) ?? 30
        return WorkoutViewModel.estimatedCalories(for: exercise, durationMinutes: duration)
    }
    
    var isValid: Bool {
        (Int(durationMinutes) != nil && Int(durationMinutes)! > 0) &&
        (!selectedExercise.isEmpty || !customExercise.isEmpty)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Jenis Olahraga") {
                    if customExercise.isEmpty {
                        Picker("Pilih Olahraga", selection: $selectedExercise) {
                            ForEach(WorkoutViewModel.commonExercises, id: \.self) { exercise in
                                Text(exercise).tag(exercise)
                            }
                        }
                    }
                    
                    TextField("Atau masukkan olahraga lain", text: $customExercise)
                }
                
                Section("Durasi") {
                    HStack {
                        TextField("30", text: $durationMinutes)
                            .keyboardType(.numberPad)
                        Text("menit")
                    }
                }
                
                Section("Intensitas") {
                    Picker("Intensitas", selection: $selectedIntensity) {
                        ForEach(intensities, id: \.self) { intensity in
                            Text(intensity).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Perkiraan") {
                    HStack {
                        Label("Kalori Terbakar", systemImage: "flame.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("\(estimatedCalories)")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                    }
                }
                
                Section("Catatan (Opsional)") {
                    TextField("Contoh: Merasa lelah", text: $note)
                }
                
                Section {
                    Button(action: {
                        let exercise = customExercise.isEmpty ? selectedExercise : customExercise
                        workoutVM.addWorkout(
                            exerciseName: exercise,
                            durationMinutes: Int(durationMinutes) ?? 30,
                            caloriesBurned: estimatedCalories,
                            intensity: selectedIntensity,
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
            .navigationTitle("Tambah Olahraga")
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
    WorkoutView()
}
