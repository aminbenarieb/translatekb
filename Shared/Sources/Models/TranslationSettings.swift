import Foundation

/// Snapshot of the user's translation preferences, read from App Group storage.
public struct TranslationSettings: Sendable, Equatable {
    public var sourceLanguage: Language?
    public var targetLanguage: Language
    public var tone: Tone

    public init(sourceLanguage: Language?, targetLanguage: Language, tone: Tone) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.tone = tone
    }

    public static let defaults = TranslationSettings(
        sourceLanguage: nil,
        targetLanguage: .english,
        tone: .neutral
    )
}
