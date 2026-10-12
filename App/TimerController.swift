import ActivityKit
import Foundation

/// Starts/stops tracking and shows/hides the Dynamic Island bubble.
@MainActor
final class TimerController {
    static let shared = TimerController()
    private let store = UsageStore.shared

    func start() async {
        let now = Date.now
        let usedToday = store.totalSeconds(on: now, now: now)
        store.beginSession(at: now)

        let state = InstaTimerAttributes.ContentState(
            countingFrom: now.addingTimeInterval(-usedToday)
        )
        // High relevance so InstaTimer gets the main Dynamic Island spot over other Live Activities.
        let content = ActivityContent(state: state, staleDate: nil, relevanceScore: 100)

        if let existing = Activity<InstaTimerAttributes>.activities.first {
            await existing.update(content)
            report("Bubble updated (\(existing.activityState)).")
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            report("Live Activities are turned off for InstaTimer in Settings.")
            return
        }
        do {
            let activity = try Activity.request(attributes: InstaTimerAttributes(), content: content, pushType: nil)
            report("Bubble started (\(activity.activityState)). Swipe up to see it.")
        } catch {
            report("Couldn't start bubble: \(error.localizedDescription) — \(error)")
        }
    }

    /// Shown in the app's Status section so problems are visible on the phone.
    private func report(_ message: String) {
        let time = Date.now.formatted(date: .omitted, time: .standard)
        UserDefaults.standard.set("\(time): \(message)", forKey: "lastBubbleMessage")
    }

    func stop() async {
        store.endSession()
        let running = Activity<InstaTimerAttributes>.activities
        for activity in running {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        report("Stopped (\(running.count) bubble(s) closed).")
    }
}
