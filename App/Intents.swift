import AppIntents

/// Run by the "Instagram is opened" automation.
struct StartInstagramTimer: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start Instagram Timer"
    static var description = IntentDescription("Starts tracking and shows the timer bubble. Use it in an automation for when Instagram opens.")

    func perform() async throws -> some IntentResult {
        await TimerController.shared.start()
        return .result()
    }
}

/// Run by the "Instagram is closed" automation.
struct StopInstagramTimer: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Instagram Timer"
    static var description = IntentDescription("Saves the session and hides the timer bubble. Use it in an automation for when Instagram closes.")

    func perform() async throws -> some IntentResult {
        await TimerController.shared.stop()
        return .result()
    }
}

struct InstaTimerShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartInstagramTimer(),
            phrases: ["Start \(.applicationName)"],
            shortTitle: "Start Instagram Timer",
            systemImageName: "timer"
        )
        AppShortcut(
            intent: StopInstagramTimer(),
            phrases: ["Stop \(.applicationName)"],
            shortTitle: "Stop Instagram Timer",
            systemImageName: "stop.circle"
        )
    }
}
