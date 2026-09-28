import SwiftUI

struct VoiceButton: View {
    let state: AvatarState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 82, height: 82)

                Circle()
                    .stroke(.white.opacity(0.20), lineWidth: 1)
                    .frame(width: 82, height: 82)

                Image(systemName: state.systemImage)
                    .font(.system(size: 29, weight: .medium))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, isActive: state == .listening || state == .speaking)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(state == .listening ? "Stop listening" : "Talk to Persephone")
    }
}
