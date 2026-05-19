import Foundation

/// Default adapter: passes text through unchanged. Used for v1 (no AI tone)
/// and as a safe fallback whenever a richer adapter is unavailable.
///
/// Reports `supportedTones() == Tone.allCases` rather than `[.neutral]`. The
/// adapter "supports" every tone in the sense that it will not fail or
/// time-out for any of them — it just returns the input unchanged. Reporting
/// the full list lets UI surfaces show every tone option without claiming
/// they're unavailable.
public struct NoOpToneAdapter: ToneAdapter {
    public let identifier = "noop"
    public let displayName = "No tone adjustment"

    public init() {}

    public func isAvailable() async -> Bool { true }

    public func supportedTones() -> [Tone] { Tone.allCases }

    public func adapt(_ text: String, tone: Tone, language: Language) async throws -> String {
        text
    }
}
