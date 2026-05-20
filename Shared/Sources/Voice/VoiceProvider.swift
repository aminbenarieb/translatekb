import Foundation

/// Transcribes audio into text. Sits next to `TranslationProvider` /
/// `ToneAdapter` in the pipeline so the keyboard can stay agnostic about
/// which speech backend runs (Apple Speech, on-device Whisper, cloud).
///
/// v1 ships with a stub `AppleSpeechVoiceProvider` (`isAvailable() == false`).
/// Real on-device transcription is v2 work — see `docs/roadmap-v0.2.md`.
public protocol VoiceProvider: Sendable {
    /// Snake_case ASCII identifier used in logs and telemetry.
    var identifier: String { get }

    /// Human-readable name for Settings / dev tools.
    var displayName: String { get }

    /// Whether the provider can actually serve a request right now —
    /// permissions, model availability, OS version, etc.
    func isAvailable() async -> Bool

    /// Languages the provider can transcribe. May be a subset of
    /// `TranslationProvider.supportedSourceLanguages()`.
    func supportedLanguages() async -> [Language]

    /// Convert raw audio to text in the given language. Implementations
    /// must throw `TranslationError` on failure so the pipeline can
    /// surface a uniform error to the UI.
    func transcribe(
        audio: AudioBuffer,
        language: Language
    ) async throws -> String

    /// Optional warm-up so the first transcription isn't slower than the
    /// rest. Default no-op.
    func prewarm() async
}

public extension VoiceProvider {
    func prewarm() async {}
}
