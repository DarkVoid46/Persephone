import SwiftUI

struct PersephoneAvatarView: View {
    let state: AvatarState
    let microphoneLevel: CGFloat

    @State private var animate = false

    private var avatarScale: CGFloat {
        switch state {
        case .idle:
            return animate ? 1.012 : 0.995
        case .listening:
            return 1.0 + (microphoneLevel * 0.045)
        case .thinking:
            return 1.01
        case .speaking:
            return animate ? 1.018 : 1.0
        }
    }

    private var avatarRotation: Double {
        switch state {
        case .thinking:
            return animate ? 1.2 : -1.2
        default:
            return 0
        }
    }

    private var avatarOffset: CGFloat {
        switch state {
        case .speaking:
            return animate ? -3 : 2
        default:
            return 0
        }
    }

    private var ringOpacity: Double {
        switch state {
        case .idle: return 0.12
        case .listening: return 0.32 + Double(microphoneLevel) * 0.35
        case .thinking: return 0.24
        case .speaking: return 0.34
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(ringOpacity), lineWidth: 1)
                .frame(width: 330, height: 330)
                .scaleEffect(animate ? 1.07 : 0.96)
                .blur(radius: 0.4)

            Circle()
                .fill(.white.opacity(state == .listening ? 0.08 : 0.035))
                .frame(width: 300, height: 300)
                .blur(radius: 18)

            Image("PersephoneAvatar")
                .resizable()
                .scaledToFill()
                .frame(width: 286, height: 370)
                .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .stroke(.white.opacity(0.18), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.28), radius: 30, y: 18)
                .scaleEffect(avatarScale)
                .rotationEffect(.degrees(avatarRotation))
                .offset(y: avatarOffset)
        }
        .animation(
            state == .listening
                ? .easeOut(duration: 0.10)
                : .easeInOut(duration: state == .thinking ? 1.6 : 2.2).repeatForever(autoreverses: true),
            value: animate
        )
        .animation(.easeOut(duration: 0.10), value: microphoneLevel)
        .onAppear { animate = true }
        .onChange(of: state) { _, _ in
            animate = false
            DispatchQueue.main.async {
                animate = true
            }
        }
        .accessibilityLabel("Persephone avatar, \(state.label)")
    }
}
