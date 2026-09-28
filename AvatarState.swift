import Foundation

enum AvatarState: String, CaseIterable {
    case idle
    case listening
    case thinking
    case speaking

    var label: String {
        switch self {
        case .idle: return "Ready"
        case .listening: return "Listening"
        case .thinking: return "Thinking"
        case .speaking: return "Speaking"
        }
    }

    var systemImage: String {
        switch self {
        case .idle: return "moon.stars.fill"
        case .listening: return "waveform"
        case .thinking: return "sparkles"
        case .speaking: return "speaker.wave.2.fill"
        }
    }
}
