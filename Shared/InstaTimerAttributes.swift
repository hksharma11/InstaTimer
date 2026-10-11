import ActivityKit
import Foundation

/// Shared between the app (which starts/updates the Live Activity)
/// and the widget extension (which draws the bubble).
struct InstaTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// The timer counts up from this date. It is set to
        /// "now minus time already used today", so the bubble shows
        /// today's running total, not just the current session.
        var countingFrom: Date
    }
}
