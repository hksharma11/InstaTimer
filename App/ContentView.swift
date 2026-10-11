import ActivityKit
import SwiftUI

private let igGradient = LinearGradient(
    colors: [Color(red: 0.98, green: 0.73, blue: 0.29), Color(red: 0.91, green: 0.20, blue: 0.45), Color(red: 0.53, green: 0.23, blue: 0.85)],
    startPoint: .bottomLeading, endPoint: .topTrailing
)

struct ContentView: View {
    @State private var refresh = 0
    @State private var confirmReset = false
    @AppStorage("lastBubbleMessage") private var lastMessage = "Tap Start timer to test."

    private let store = UsageStore.shared

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        let _ = refresh
                        VStack(spacing: 8) {
                            Text("Instagram today")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                            Text(formatDuration(store.totalSeconds(on: context.date, now: context.date)))
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                            Label(store.isTracking ? "Tracking now" : "Not tracking",
                                  systemImage: store.isTracking ? "record.circle" : "pause.circle")
                                .font(.caption.bold())
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                    .listRowBackground(igGradient)
                }

                if !ActivityAuthorizationInfo().areActivitiesEnabled {
                    Section {
                        Label("Live Activities are off. Turn them on in Settings › InstaTimer so the bubble can show.",
                              systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }
                }

                Section("Last 7 days") {
                    WeekChart(store: store)
                        .id(refresh)
                }

                Section("Test the bubble") {
                    Button {
                        Task { await TimerController.shared.start(); refresh += 1 }
                    } label: { Label("Start timer", systemImage: "play.fill") }
                    Button {
                        Task { await TimerController.shared.stop(); refresh += 1 }
                    } label: { Label("Stop timer", systemImage: "stop.fill") }
                }

                Section("Status") {
                    TimelineView(.periodic(from: .now, by: 1)) { _ in
                        VStack(alignment: .leading, spacing: 6) {
                            StatusRow(title: "Live Activities", ok: ActivityAuthorizationInfo().areActivitiesEnabled,
                                      okText: "Allowed", badText: "Off in Settings")
                            StatusRow(title: "Timer widget", ok: widgetInstalled,
                                      okText: "Installed", badText: "Missing")
                            StatusRow(title: "Bubbles running", ok: !Activity<InstaTimerAttributes>.activities.isEmpty,
                                      okText: "\(Activity<InstaTimerAttributes>.activities.count)", badText: "0")
                            Text(lastMessage)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                    }
                }

                Section("Signing") {
                    ForEach(SigningInfo.all()) { info in
                        VStack(alignment: .leading, spacing: 4) {
                            StatusRow(title: info.id, ok: info.profileMatches,
                                      okText: "Signed OK", badText: info.profileAppID == nil ? "No profile" : "Mismatch")
                            Group {
                                Text("Bundle: \(info.bundleID)")
                                Text("Profile: \(info.profileAppID ?? "none")")
                                if let name = info.profileName { Text("Profile name: \(name)") }
                                if let ext = info.extensionPoint { Text("Type: \(ext)") }
                            }
                            .font(.caption2.monospaced())
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                        }
                    }
                }

                Section("One-time setup") {
                    SetupStep(n: 1, text: "Open the **Shortcuts** app › **Automation** tab › **+**.")
                    SetupStep(n: 2, text: "Choose **App** › pick **Instagram** › tick **Is Opened** only › select **Run Immediately**.")
                    SetupStep(n: 3, text: "Tap **New Blank Automation** › Add Action › search **Start Instagram Timer** › Done.")
                    SetupStep(n: 4, text: "Repeat with **Is Closed** and the action **Stop Instagram Timer**.")
                    SetupStep(n: 5, text: "Open Instagram. The timer appears in the Dynamic Island.")
                }

                Section {
                    Button("Reset all data", role: .destructive) { confirmReset = true }
                }
            }
            .navigationTitle("InstaTimer")
            .confirmationDialog("Erase all usage history?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Erase", role: .destructive) {
                    Task { await TimerController.shared.stop(); store.reset(); refresh += 1 }
                }
            }
        }
    }
}

/// True if the widget extension (which draws the bubble) made it into the installed app.
private var widgetInstalled: Bool {
    guard let url = Bundle.main.builtInPlugInsURL,
          let items = try? FileManager.default.contentsOfDirectory(atPath: url.path) else { return false }
    return items.contains { $0.hasSuffix(".appex") }
}

private struct StatusRow: View {
    let title: String
    let ok: Bool
    let okText: String
    let badText: String

    var body: some View {
        HStack {
            Text(title).font(.subheadline)
            Spacer()
            Label(ok ? okText : badText, systemImage: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.subheadline.bold())
                .foregroundStyle(ok ? .green : .red)
        }
    }
}

private struct SetupStep: View {
    let n: Int
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(n)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(igGradient))
            Text(text).font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

private struct WeekChart: View {
    let store: UsageStore

    var body: some View {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let days = (0..<7).reversed().map { cal.date(byAdding: .day, value: -$0, to: today)! }
        let values = days.map { store.totalSeconds(on: $0) }
        let maxValue = max(values.max() ?? 0, 60)

        HStack(alignment: .bottom, spacing: 10) {
            ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                VStack(spacing: 6) {
                    Text(values[i] > 0 ? shortDuration(values[i]) : "")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(igGradient)
                        .frame(height: max(4, 110 * values[i] / maxValue))
                    Text(day, format: .dateTime.weekday(.narrow))
                        .font(.caption)
                        .foregroundStyle(cal.isDateInToday(day) ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 160, alignment: .bottom)
        .padding(.vertical, 8)
    }

    private func shortDuration(_ s: Double) -> String {
        let m = Int(s) / 60
        return m >= 60 ? "\(m / 60)h\(m % 60)" : "\(m)m"
    }
}
