import Foundation

/// Placeholder for the future Apple Speech-backed `VoiceProvider`. Ships in
/// v0.2 as a stub so the architecture is wired and v2 lights up by replacing
/// this file's body. Apple's `SFSpeechRecognizer` is on-device since iOS 13
/// and free — no API key, no per-minute cost.
///
/// v1 reports unavailable and refuses transcription. The keyboard UI hides
/// the mic button when `isAvailable() == false`.
public struct AppleSpeechVoiceProvider: VoiceProvider {
    public let identifier = "apple_speech"
    public let displayName = "Apple Speech"

    public init() {}

    public func isAvailable() async -> Bool {
        // v2: check SFSpeechRecognizer.authorizationStatus(), microphone
        //     permission, and SFSpeechRecognizer(locale:).isAvailable.
        false
    }

    public func supportedLanguages() async -> [Language] {
        // v2: SFSpeechRecognizer.supportedLocales() mapped through Language.preset(for:).
        []
    }

    public func transcribe(
        audio: AudioBuffer,
        language: Language
    ) async throws -> String {
        throw TranslationError.providerUnavailable
    }
}

/// Mock for unit tests — returns a configurable canned transcription.
public final class MockVoiceProvider: VoiceProvider {
    public let identifier = "mock_voice"
    public let displayName = "Mock Voice"

    private let cannedResponse: String
    private let shouldFail: TranslationError?

    public init(cannedResponse: String = "[mock transcription]", shouldFail: TranslationError? = nil) {
        self.cannedResponse = cannedResponse
        self.shouldFail = shouldFail
    }

    public func isAvailable() async -> Bool { shouldFail == nil }

    public func supportedLanguages() async -> [Language] { Language.allPresets }

    public func transcribe(audio: AudioBuffer, language: Language) async throws -> String {
        if let shouldFail { throw shouldFail }
        return cannedResponse
    }
}
