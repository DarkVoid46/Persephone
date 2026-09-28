import Foundation

/// Phase 2 connection point for OpenAI Realtime.
///
/// Keep the permanent OpenAI API key on a server you control.
/// The iPhone app should receive only short-lived credentials or use
/// a server-mediated WebRTC setup.
protocol RealtimeService {
    func connect() async throws
    func disconnect() async
}

/// Lets the V1 UI compile and evolve before the live voice backend is wired in.
final class MockRealtimeService: RealtimeService {
    func connect() async throws { }
    func disconnect() async { }
}
