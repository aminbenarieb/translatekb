import Foundation

/// Placeholder for a future cloud provider (OpenAI, DeepL, Anthropic, etc.).
/// MVP ships Apple-only, so this always reports unavailable and refuses requests.
/// Wire up a real client in week 3–4 without touching the keyboard.
public final class CloudTranslationProvider: TranslationProvider {
    public let identifier = "cloud_translation_stub"
    public let displayName = "Cloud Translation (coming soon)"

    public init() {}

    public func isAvailable() async -> Bool { false }

    public func supportedSourceLanguages() async -> [Language] { [] }
    public func supportedTargetLanguages() async -> [Language] { [] }

    public func translate(
        _ text: String,
        from source: Language?,
        to target: Language
    ) async throws -> TranslationResult {
        throw TranslationError.providerUnavailable
    }
}
