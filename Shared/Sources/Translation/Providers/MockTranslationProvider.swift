import Foundation

/// Deterministic provider for unit tests and previews. Returns input wrapped in a
/// marker so test assertions can verify the pipeline called the provider.
public final class MockTranslationProvider: TranslationProvider {
    public let identifier = "mock_translation"
    public let displayName = "Mock Translation"

    private let prefix: String
    private let simulatedDelayMs: Int
    private let shouldFail: TranslationError?

    public init(
        prefix: String = "[mock]",
        simulatedDelayMs: Int = 0,
        shouldFail: TranslationError? = nil
    ) {
        self.prefix = prefix
        self.simulatedDelayMs = simulatedDelayMs
        self.shouldFail = shouldFail
    }

    public func isAvailable() async -> Bool { true }

    public func supportedSourceLanguages() async -> [Language] {
        Language.allPresets
    }

    public func supportedTargetLanguages() async -> [Language] {
        Language.allPresets
    }

    public func translate(
        _ text: String,
        from source: Language?,
        to target: Language
    ) async throws -> TranslationResult {
        if let shouldFail {
            throw shouldFail
        }
        if simulatedDelayMs > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedDelayMs) * 1_000_000)
        }
        let start = Date()
        let detectedSource = source ?? .english
        let translated = "\(prefix) \(target.code): \(text)"
        let elapsed = Int(Date().timeIntervalSince(start) * 1000)
        return TranslationResult(
            originalText: text,
            translatedText: translated,
            sourceLanguage: detectedSource,
            targetLanguage: target,
            providerIdentifier: identifier,
            adapterIdentifier: nil,
            durationMs: elapsed
        )
    }
}
