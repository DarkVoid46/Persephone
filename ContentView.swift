import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PersephoneViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.055, green: 0.045, blue: 0.11),
                    Color(red: 0.12, green: 0.075, blue: 0.18),
                    Color(red: 0.035, green: 0.03, blue: 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.white.opacity(0.08),
                    .clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 360
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("PERSEPHONE")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .tracking(4.5)
                        .foregroundStyle(.white.opacity(0.78))

                    Text("Personal Assistant")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.42))
                }
                .padding(.top, 14)

                Spacer(minLength: 18)

                PersephoneAvatarView(
                    state: viewModel.state,
                    microphoneLevel: viewModel.microphoneLevel
                )

                Spacer(minLength: 18)

                VStack(spacing: 7) {
                    Label(viewModel.state.label, systemImage: viewModel.state.systemImage)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(viewModel.statusText)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.60))
                }

                Spacer(minLength: 24)

                VoiceButton(
                    state: viewModel.state,
                    action: viewModel.handlePrimaryAction
                )

                Text(viewModel.state == .listening ? "Tap again when you're finished" : "Tap to speak")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.38))
                    .padding(.top, 12)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            viewModel.startFromShortcutIfNeeded()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                viewModel.startFromShortcutIfNeeded()
            }
        }
    }
}

#Preview {
    ContentView()
}
