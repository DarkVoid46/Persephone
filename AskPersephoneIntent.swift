import AppIntents

struct AskPersephoneIntent: AppIntent {
    static var title: LocalizedStringResource = "Ask Persephone"
    static var description = IntentDescription("Open Persephone ready to listen.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(true, forKey: "persephone.autoListenOnLaunch")
        return .result()
    }
}

struct PersephoneShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AskPersephoneIntent(),
            phrases: [
                "Ask \(.applicationName)",
                "Talk to \(.applicationName)",
                "Open \(.applicationName)"
            ],
            shortTitle: "Ask Persephone",
            systemImageName: "moon.stars.fill"
        )
    }
}
