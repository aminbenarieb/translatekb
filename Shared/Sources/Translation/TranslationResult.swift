import Foundation

/// Output of a translation, optionally with tone adaptation applied.
public struct TranslationResult: Sendable {
    public let originalText: String
    public let translatedText: String
    public let sourceLanguage: Language
    public let targetLanguage: Language
    public let providerIdentifier: String
    public let adapterIdentifier: String?
    public let durationMs: Int

    public init(
        originalText: String,
        translatedText: String,
        sourceLanguage: Language,
        targetLanguage: Language,
        providerIdentifier: String,
        adapterIdentifier: String? = nil,
        durationMs: Int
    ) {
        self.originalText = originalText
        self.translatedText = translatedText
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.providerIdentifier = providerIdentifier
        self.adapterIdentifier = adapterIdentifier
        self.durationMs = durationMs
    }

    /// Returns a copy with the translated text replaced by an adapter's output.
    public func withAdaptedText(_ adapted: String, adapterIdentifier: String) -> TranslationResult {
        TranslationResult(
            originalText: originalText,
            translatedText: adapted,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            providerIdentifier: providerIdentifier,
            adapterIdentifier: adapterIdentifier,
            durationMs: durationMs
        )
    }
}
