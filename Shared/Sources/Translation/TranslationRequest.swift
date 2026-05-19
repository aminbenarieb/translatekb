import Foundation

/// One translation job: source text, optional source language hint, target language, and desired tone.
public struct TranslationRequest: Sendable {
    public let text: String
    public let sourceLanguage: Language?
    public let targetLanguage: Language
    public let tone: Tone

    public init(
        text: String,
        sourceLanguage: Language? = nil,
        targetLanguage: Language,
        tone: Tone = .neutral
    ) {
        self.text = text
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.tone = tone
    }
}
