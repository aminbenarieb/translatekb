import Foundation

/// Rewrites already-translated text in a requested tone. Implementations MUST
/// preserve meaning and MUST output in the same language as input. If a tone is
/// not supported (or the adapter is the NoOp adapter), they return text unchanged.
public protocol ToneAdapter: Sendable {
    var identifier: String { get }
    var displayName: String { get }

    func isAvailable() async -> Bool

    func supportedTones() -> [Tone]

    func adapt(
        _ text: String,
        tone: Tone,
        language: Language
    ) async throws -> String

    func prewarm() async
}

public extension ToneAdapter {
    func prewarm() async {}
}
