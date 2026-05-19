import Foundation
import os
#if canImport(Translation)
import Translation
#endif

/// Translation backed by Apple's on-device Translation framework.
///
/// - iOS 18+: uses the programmatic `TranslationSession` exposed via
///   `AppleTranslationSessionBridge`. The keyboard injects the bridge.
/// - iOS 17.4–17.x: programmatic API is unavailable, so we report unavailable;
///   the main app surfaces an "update to iOS 18" message and can fall back to
///   the system overlay sheet for ad-hoc translations.
public final class AppleTranslationProvider: TranslationProvider, @unchecked Sendable {
    public let identifier = "apple_translation"
    public let displayName = "Apple Translation"

    private let logger = Logger(subsystem: "com.aminbenarieb.translatekeyboard", category: "apple_provider")
    private let bridgeProvider: @Sendable () async -> AnyObject?

    /// - Parameter bridgeProvider: closure returning the iOS 18+ session bridge.
    ///   On iOS 17.x, pass `{ nil }`. The closure-of-AnyObject indirection lets
    ///   this type compile when the host has no SwiftUI / iOS 18 availability.
    public init(bridgeProvider: @escaping @Sendable () async -> AnyObject?) {
        self.bridgeProvider = bridgeProvider
    }

    public func isAvailable() async -> Bool {
        if #available(iOS 18.0, *) {
            return (await bridgeProvider()) != nil
        }
        return false
    }

    public func supportedSourceLanguages() async -> [Language] {
        await Self.installedLanguages()
    }

    public func supportedTargetLanguages() async -> [Language] {
        await Self.installedLanguages()
    }

    public func translate(
        _ text: String,
        from source: Language?,
        to target: Language
    ) async throws -> TranslationResult {
        guard #available(iOS 18.0, *) else {
            throw TranslationError.providerUnavailable
        }
        guard let bridge = await bridgeProvider() as? AppleTranslationSessionBridge else {
            throw TranslationError.providerUnavailable
        }

        let start = Date()
        let sourceLocale = source.map { Locale.Language(identifier: $0.code) }
        let targetLocale = Locale.Language(identifier: target.code)

        do {
            let session = try await bridge.session(source: sourceLocale, target: targetLocale)
            let response = try await session.translate(text)
            let detectedSource: Language
            if let detectedCode = response.sourceLanguage.languageCode?.identifier,
               let preset = Language.preset(for: detectedCode) {
                detectedSource = preset
            } else {
                detectedSource = source ?? .english
            }
            let elapsed = Int(Date().timeIntervalSince(start) * 1000)
            return TranslationResult(
                originalText: text,
                translatedText: response.targetText,
                sourceLanguage: detectedSource,
                targetLanguage: target,
                providerIdentifier: identifier,
                adapterIdentifier: nil,
                durationMs: elapsed
            )
        } catch let error as TranslationError {
            throw error
        } catch {
            logger.error("apple translation failed: \(error.localizedDescription, privacy: .public)")
            throw TranslationError.networkError(underlying: error)
        }
    }

    public func prewarm() async {
        guard #available(iOS 18.0, *) else { return }
        _ = await bridgeProvider()
    }

    /// Best-effort list of languages we expose in pickers. We don't query the
    /// system for installed packs here — that lives in the main app's language
    /// pack management UI — so we return the curated preset list.
    private static func installedLanguages() async -> [Language] {
        Language.allPresets
    }
}
