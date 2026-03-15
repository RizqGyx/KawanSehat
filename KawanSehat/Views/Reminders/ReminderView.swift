import SwiftUI

// MARK: - ReminderView
/// Feature 2: Health goal reminders + smart re-engagement notifications
struct ReminderView: View {
    @EnvironmentObject var reminderVM: ReminderViewModel
    @EnvironmentObject var notificationService: NotificationService
    @State private var showMealHistorySheet = false
    
    var body: some View {
        NavigationStack {
            List {
                // Notification permission banner
                if !notificationService.isAuthorized {
                    Section {
                        PermissionBanner {
                            Task { await reminderVM.requestPermission() }
                        }
                    }
                }
                
                // Smart Re-engagement Section
                Section {
                    SmartReminderRow(vm: reminderVM)
                } header: {
                    Label("Pengingat Cerdas", systemImage: "brain.head.profile")
                } footer: {
                    Text("Kirim notifikasi motivasi jika kamu tidak membuka app dalam waktu lama.")
                }
                
                // Goal-based reminders
                Section {
                    ForEach(reminderVM.reminders.indices, id: \.self) { index in
                        ReminderRow(
                            reminder: reminderVM.reminders[index],
                            onToggle: {
                                reminderVM.toggleReminder(at: index)
                            },
                            onTimeChange: { date in
                                reminderVM.setReminderTime(at: index, from: date)
                            },
                            selectedTime: reminderVM.reminderTime(at: index)
                        )
                    }
                } header: {
                    Label("Pengingat Tujuan Kesehatan", systemImage: "target")
                } footer: {
                    Text("Pengingat harian untuk membantu kamu mencapai tujuan kesehatan.")
                }
                
                // App usage info
                Section {
                    HStack {
                        Label("Terakhir buka app", systemImage: "clock.fill")
                        Spacer()
                        Text(reminderVM.lastOpenLabel)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                } header: {
                    Label("Info Penggunaan", systemImage: "chart.bar.fill")
                }
            }
            .navigationTitle("Pengingat")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showMealHistorySheet = true
                    } label: {
                        Label("Riwayat", systemImage: "fork.knife")
                    }
                }
            }
            .alert("Izinkan Notifikasi", isPresented: $reminderVM.showPermissionAlert) {
                Button("Izinkan") {
                    Task {
                        await reminderVM.requestPermission()
                        // Allow a moment for permission to be processed
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        // Try to enable the reminder again
                        reminderVM.toggleReminder(at: 0)
                    }
                }
                Button("Nanti", role: .cancel) {}
            } message: {
                Text("HealthBudget butuh izin notifikasi untuk mengirim pengingat kesehatanmu.")
            }
            .onAppear {
                Task {
                    await notificationService.requestPermission()
                    reminderVM.isNotificationAuthorized = notificationService.isAuthorized
                }
            }
            .sheet(isPresented: $showMealHistorySheet) {
                MealReminderHistorySheet()
            }
        }
    }
}

// MARK: - Permission Banner
struct PermissionBanner: View {
    let onRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Notifikasi dinonaktifkan")
                    .font(.subheadline.bold())
                Text("Aktifkan untuk menerima pengingat kesehatanmu")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Aktifkan", action: onRequest)
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Smart Reminder Row
struct SmartReminderRow: View {
    @ObservedObject var vm: ReminderViewModel
    @State private var showThresholdPicker = false
    
    let thresholdOptions = [6, 12, 24, 48, 72]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("Aktifkan pengingat cerdas", systemImage: "sparkles")
                Spacer()
                Toggle("", isOn: Binding(
                    get: { vm.smartConfig.isEnabled },
                    set: { _ in vm.toggleSmartReminder() }
                ))
                .labelsHidden()
            }
            
            if vm.smartConfig.isEnabled {
                Divider().padding(.vertical, 8)
                
                HStack {
                    Text("Ingatkan setelah")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    
                    // Threshold picker
                    Menu {
                        ForEach(thresholdOptions, id: \.self) { hours in
                            Button("\(hours) jam tidak aktif") {
                                vm.updateSmartThreshold(hours)
                            }
                        }
                    } label: {
                        HStack {
                            Text("\(vm.smartConfig.inactiveHoursThreshold) jam tidak aktif")
                                .font(.subheadline)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                    }
                }
            }
        }
    }
}

// MARK: - Reminder Row
struct ReminderRow: View {
    let reminder: HealthReminder
    let onToggle: () -> Void
    let onTimeChange: (Date) -> Void
    let selectedTime: Date
    @State private var showTimePickerSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // Goal icon and name
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(reminder.goalType.rawValue)
                            .font(.subheadline.bold())
                        if reminder.isEnabled {
                            Text(reminder.timeFormatted + " · " + reminder.daysLabel)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } icon: {
                    Image(systemName: reminder.goalType.icon)
                        .foregroundColor(reminder.isEnabled ? .green : .secondary)
                        .frame(width: 24)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { reminder.isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
            }
            
            // Show time when enabled
            if reminder.isEnabled {
                Divider().padding(.vertical, 8)
                
                Button {
                    showTimePickerSheet = true
                } label: {
                    HStack {
                        Label("Jam pengingat", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(reminder.timeFormatted)
                            .foregroundColor(.green)
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showTimePickerSheet) {
            TimePickerSheet(
                selectedTime: selectedTime,
                onTimeChange: onTimeChange
            )
        }
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    let selectedTime: Date
    let onTimeChange: (Date) -> Void
    @State private var tempTime: Date
    
    init(selectedTime: Date, onTimeChange: @escaping (Date) -> Void) {
        self.selectedTime = selectedTime
        self.onTimeChange = onTimeChange
        _tempTime = State(initialValue: selectedTime)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Pilih waktu",
                    selection: $tempTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
                
                Button {
                    onTimeChange(tempTime)
                    dismiss()
                } label: {
                    Text("Simpan")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Atur Waktu Pengingat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Batal") { dismiss() }
                }
            }
        }
    }
}
