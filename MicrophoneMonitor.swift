import AVFoundation
import Foundation

final class MicrophoneMonitor {
    var onLevel: ((Double) -> Void)?

    private let engine = AVAudioEngine()
    private var tapInstalled = false

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func start() throws {
        if engine.isRunning { return }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetooth]
        )
        try session.setActive(true)

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)

        if !tapInstalled {
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                guard let channel = buffer.floatChannelData?.pointee else { return }

                let frameCount = Int(buffer.frameLength)
                guard frameCount > 0 else { return }

                var sum: Float = 0
                for frame in 0..<frameCount {
                    let sample = channel[frame]
                    sum += sample * sample
                }

                let rms = sqrt(sum / Float(frameCount))
                let db = 20 * log10(max(rms, 0.000_001))
                let normalized = min(max((Double(db) + 55.0) / 55.0, 0), 1)

                DispatchQueue.main.async {
                    self?.onLevel?(normalized)
                }
            }
            tapInstalled = true
        }

        engine.prepare()
        try engine.start()
    }

    func stop() {
        guard engine.isRunning else { return }
        engine.stop()

        do {
            try AVAudioSession.sharedInstance().setActive(
                false,
                options: [.notifyOthersOnDeactivation]
            )
        } catch {
            // Safe to ignore during shutdown; the next start() reconfigures the session.
        }

        DispatchQueue.main.async { [weak self] in
            self?.onLevel?(0)
        }
    }

    deinit {
        if tapInstalled {
            engine.inputNode.removeTap(onBus: 0)
        }
    }
}
