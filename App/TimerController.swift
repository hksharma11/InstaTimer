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
        let content = ActivityContent(state: state, staleDate: nil)

        if let existing = Activity<InstaTimerAttributes>.activities.first {
            await existing.update(content)
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        do {
            _ = try Activity.request(attributes: InstaTimerAttributes(), content: content, pushType: nil)
        } catch {
            print("Could not start Live Activity: \(error)")
        }
    }

    func stop() async {
        store.endSession()
        for activity in Activity<InstaTimerAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
