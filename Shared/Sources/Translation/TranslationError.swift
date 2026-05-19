import Foundation

public enum TranslationError: Error, Sendable {
    case providerUnavailable
    case unsupportedLanguagePair(from: Language?, to: Language)
    case networkError(underlying: Error)
    case timeout
    case rateLimitExceeded
    case invalidInput(reason: String)
    case adapterFailed(underlying: Error)
    case languagePackNotDownloaded(Language, Language)
    case fullAccessDenied
}

extension TranslationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .providerUnavailable:
            return "Translation provider is not available."
        case .unsupportedLanguagePair(let from, let to):
            let fromName = from?.displayName ?? "auto"
            return "Cannot translate \(fromName) → \(to.displayName)."
        case .networkError:
            return "Network error. Check your connection."
        case .timeout:
            return "Translation timed out."
        case .rateLimitExceeded:
            return "Too many requests. Try again later."
        case .invalidInput(let reason):
            return "Invalid input: \(reason)."
        case .adapterFailed:
            return "Tone adjustment failed."
        case .languagePackNotDownloaded:
            return "Open the app to download the language pack."
        case .fullAccessDenied:
            return "Enable Full Access in Settings to translate."
        }
    }
}
