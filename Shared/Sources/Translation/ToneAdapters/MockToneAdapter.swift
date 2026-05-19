import Foundation

/// Deterministic adapter for unit tests. Wraps the input with the tone name
/// so tests can verify which tone was applied.
public final class MockToneAdapter: ToneAdapter {
    public let identifier = "mock_tone"
    public let displayName = "Mock Tone"

    private let shouldFail: Error?

    public init(shouldFail: Error? = nil) {
        self.shouldFail = shouldFail
    }

    public func isAvailable() async -> Bool { true }

    public func supportedTones() -> [Tone] { Tone.allCases }

    public func adapt(_ text: String, tone: Tone, language: Language) async throws -> String {
        if let shouldFail { throw shouldFail }
        guard tone != .neutral else { return text }
        return "[\(tone.rawValue)] \(text)"
    }
}
