import SwiftUI
import SwordKit

struct ReadingPlansView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            if let plan = model.selectedReadingPlan,
               let selection = model.readingPlanSelection {
                ActiveReadingPlanView(plan: plan, selection: selection)
            } else {
                List(model.readingPlans) { plan in
                    NavigationLink {
                        ReadingPlanPreview(plan: plan)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(plan.title)
                            Text(BuiltInReadingPlans.subtitles[plan.id] ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Reading Plans")
    }
}

private struct ReadingPlanPreview: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let plan: SwordReadingPlan

    var body: some View {
        List {
            Section {
                Text(BuiltInReadingPlans.notes[plan.id] ?? "")
            } header: {
                Text(BuiltInReadingPlans.subtitles[plan.id] ?? "")
            }
            Section("First Days") {
                ForEach(plan.days.prefix(3)) { day in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.title ?? "Day \(day.id)")
                        Text(day.readings.joined(separator: " · "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(plan.title)
        .toolbar {
            Button("Start Plan") {
                model.startReadingPlan(plan.id)
                dismiss()
            }
        }
    }
}

private struct ActiveReadingPlanView: View {
    @Environment(AppModel.self) private var model
    @State private var isConfirmingStop = false
    @State private var reminderTime = Calendar.current.date(
        from: DateComponents(hour: 9)
    ) ?? .now
    let plan: SwordReadingPlan
    let selection: ReadingPlanSelection

    private var progress: Double {
        Double(selection.completedDayIDs.count) / Double(plan.days.count)
    }

    var body: some View {
        List {
            Section {
                ProgressView(value: progress) {
                    Text("\(selection.completedDayIDs.count) of \(plan.days.count) days")
                }
                Text("Started \(selection.startedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Optional Reminder") {
                Toggle(
                    "Daily Reminder",
                    isOn: Binding(
                        get: { model.readingPlanReminderTime != nil },
                        set: { enabled in
                            if enabled {
                                Task { await model.setReadingPlanReminder(at: reminderTime) }
                            } else {
                                model.disableReadingPlanReminder()
                            }
                        }
                    )
                )
                if model.readingPlanReminderTime != nil {
                    DatePicker(
                        "Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: reminderTime) { _, time in
                        Task { await model.setReadingPlanReminder(at: time) }
                    }
                }
                Text("Notifications stay off until you enable this setting.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(plan.days) { day in
                Section {
                    ForEach(day.readings, id: \.self) { reading in
                        Button(reading) { model.openPlanReading(reading) }
                    }
                    Button {
                        model.toggleReadingPlanDay(day.id)
                    } label: {
                        Label(
                            selection.completedDayIDs.contains(day.id) ? "Completed" : "Mark Complete",
                            systemImage: selection.completedDayIDs.contains(day.id) ? "checkmark.circle.fill" : "circle"
                        )
                    }
                } header: {
                    Text(day.title ?? "Day \(day.id)")
                }
            }
        }
        .navigationTitle(plan.title)
        .onAppear {
            if let saved = model.readingPlanReminderTime { reminderTime = saved }
        }
        .toolbar {
            Button("Stop Plan", role: .destructive) { isConfirmingStop = true }
        }
        .confirmationDialog("Stop this reading plan?", isPresented: $isConfirmingStop) {
            Button("Stop and Delete Progress", role: .destructive) { model.stopReadingPlan() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Bookmarks, notes, and Bible modules will not be affected.")
        }
    }
}
