import Foundation

/// Translates text from one language to another. Implementations own their own
/// network, retry, timeout, and language-pack download policy. They MUST be safe
/// to call from any actor (Sendable).
public protocol TranslationProvider: Sendable {
    /// Stable identifier used in logs, settings, telemetry. Snake_case, ASCII.
    var identifier: String { get }

    /// Human-readable name shown to the user (e.g. "Apple Translation").
    var displayName: String { get }

    /// Whether this provider can actually serve a request right now on this device.
    func isAvailable() async -> Bool

    /// Languages this provider can detect or accept as source.
    func supportedSourceLanguages() async -> [Language]

    /// Languages this provider can produce as target.
    func supportedTargetLanguages() async -> [Language]

    /// Run a translation. Must throw `TranslationError` on any failure.
    /// `source == nil` means auto-detect.
    func translate(
        _ text: String,
        from source: Language?,
        to target: Language
    ) async throws -> TranslationResult

    /// Optional warm-up so the first user translation isn't slower than the rest.
    func prewarm() async
}

public extension TranslationProvider {
    func prewarm() async {}
}
