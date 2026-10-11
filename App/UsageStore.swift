import Foundation

/// Stores Instagram usage per day (in seconds) plus the currently running session.
final class UsageStore {
    static let shared = UsageStore()

    private let defaults = UserDefaults.standard
    private let historyKey = "dailySeconds"
    private let sessionKey = "sessionStart"
    private let calendar = Calendar.current

    /// If the "Instagram closed" automation never fired, don't count more than this.
    private let maxSession: TimeInterval = 4 * 3600

    private static let keyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func dayKey(_ date: Date) -> String { keyFormatter.string(from: date) }

    var history: [String: Double] {
        defaults.dictionary(forKey: historyKey) as? [String: Double] ?? [:]
    }

    var sessionStart: Date? {
        defaults.object(forKey: sessionKey) as? Date
    }

    var isTracking: Bool { sessionStart != nil }

    /// Total seconds on the given day, including the part of a running session that falls on it.
    func totalSeconds(on day: Date, now: Date = .now) -> Double {
        var total = history[Self.dayKey(day)] ?? 0
        if let start = sessionStart {
            let dayStart = calendar.startOfDay(for: day)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            let end = min(now, start.addingTimeInterval(maxSession))
            let overlap = min(end, dayEnd).timeIntervalSince(max(start, dayStart))
            if overlap > 0 { total += overlap }
        }
        return total
    }

    func beginSession(at now: Date = .now) {
        if let start = sessionStart, now.timeIntervalSince(start) < maxSession {
            return // already running (automation fired twice)
        }
        defaults.set(now, forKey: sessionKey)
    }

    func endSession(at now: Date = .now) {
        guard let start = sessionStart else { return }
        defaults.removeObject(forKey: sessionKey)

        let end = min(now, start.addingTimeInterval(maxSession))
        guard end > start else { return }

        // Split across midnight so each day gets its share.
        var h = history
        var cursor = start
        while cursor < end {
            let nextMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: cursor))!
            let sliceEnd = min(end, nextMidnight)
            h[Self.dayKey(cursor), default: 0] += sliceEnd.timeIntervalSince(cursor)
            cursor = sliceEnd
        }
        defaults.set(h, forKey: historyKey)
    }

    func reset() {
        defaults.removeObject(forKey: historyKey)
        defaults.removeObject(forKey: sessionKey)
    }
}

func formatDuration(_ seconds: Double) -> String {
    let s = Int(seconds)
    let h = s / 3600, m = (s % 3600) / 60, sec = s % 60
    if h > 0 { return String(format: "%dh %02dm", h, m) }
    if m > 0 { return String(format: "%dm %02ds", m, sec) }
    return "\(sec)s"
}
