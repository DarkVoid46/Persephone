import Foundation
import SwiftUI

@MainActor
final class PersephoneViewModel: ObservableObject {
    @Published var state: AvatarState = .idle
    @Published var microphoneLevel: CGFloat = 0
    @Published var statusText = "Tap the moon to talk"

    private let microphone = MicrophoneMonitor()
    private var demoTask: Task<Void, Never>?

    init() {
        microphone.onLevel = { [weak self] level in
            Task { @MainActor in
                self?.microphoneLevel = CGFloat(level)
            }
        }
    }

    func handlePrimaryAction() {
        switch state {
        case .idle:
            Task { await beginListening() }
        case .listening:
            finishListeningDemo()
        case .thinking, .speaking:
            reset()
        }
    }

    func beginListening() async {
        demoTask?.cancel()

        let allowed = await microphone.requestPermission()
        guard allowed else {
            state = .idle
            statusText = "Enable Microphone access in Settings"
            return
        }

        do {
            try microphone.start()
            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                state = .listening
                statusText = "I'm listening…"
            }
        } catch {
            state = .idle
            statusText = "I couldn't start the microphone"
        }
    }

    func finishListeningDemo() {
        microphone.stop()

        withAnimation(.easeInOut(duration: 0.3)) {
            state = .thinking
            statusText = "Thinking…"
        }

        demoTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled, let self else { return }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.state = .speaking
                    self.statusText = "Speaking…"
                }
            }

            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.reset()
            }
        }
    }

    func startFromShortcutIfNeeded() {
        let key = "persephone.autoListenOnLaunch"
        guard UserDefaults.standard.bool(forKey: key) else { return }

        UserDefaults.standard.set(false, forKey: key)
        Task { await beginListening() }
    }

    func reset() {
        demoTask?.cancel()
        microphone.stop()

        withAnimation(.easeInOut(duration: 0.3)) {
            state = .idle
            microphoneLevel = 0
            statusText = "Tap the moon to talk"
        }
    }
}
