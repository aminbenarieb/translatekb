import Foundation
import os

/// Composes a `TranslationProvider` with a `ToneAdapter`. The pipeline is the
/// single entry point for the keyboard and the dev tools — UI never talks to
/// providers or adapters directly.
public final class TranslationPipeline: Sendable {
    private let provider: TranslationProvider
    private let toneAdapter: ToneAdapter
    private let voiceProvider: VoiceProvider?
    private let logger = Logger(subsystem: "com.aminbenarieb.translatekeyboard", category: "pipeline")

    public init(
        provider: TranslationProvider,
        toneAdapter: ToneAdapter,
        voiceProvider: VoiceProvider? = nil
    ) {
        self.provider = provider
        self.toneAdapter = toneAdapter
        self.voiceProvider = voiceProvider
    }

    public var providerIdentifier: String { provider.identifier }
    public var adapterIdentifier: String { toneAdapter.identifier }
    public var voiceIdentifier: String? { voiceProvider?.identifier }

    /// True when a voice-capable provider is wired in and reports available.
    /// UI uses this to decide whether to render the mic button.
    public func voiceAvailable() async -> Bool {
        guard let voice = voiceProvider else { return false }
        return await voice.isAvailable()
    }

    /// Convenience: transcribe audio and run the result through the rest of
    /// the pipeline as a normal translate request. v1 always throws because
    /// no concrete `VoiceProvider` reports `isAvailable()`.
    public func processVoice(
        _ audio: AudioBuffer,
        from source: Language?,
        to target: Language,
        tone: Tone = .neutral
    ) async throws -> TranslationResult {
        guard let voice = voiceProvider, await voice.isAvailable() else {
            throw TranslationError.providerUnavailable
        }
        let sourceLang = source ?? .english
        let transcribed = try await voice.transcribe(audio: audio, language: sourceLang)
        let request = TranslationRequest(
            text: transcribed,
            sourceLanguage: source,
            targetLanguage: target,
            tone: tone
        )
        return try await process(request)
    }

    public func process(_ request: TranslationRequest) async throws -> TranslationResult {
        let trimmed = request.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TranslationError.invalidInput(reason: "Empty text")
        }

        logger.debug("process provider=\(self.provider.identifier, privacy: .public) tone=\(request.tone.rawValue, privacy: .public) sameLang=\(self.isSameLanguageRequest(request), privacy: .public)")

        var result: TranslationResult
        if isSameLanguageRequest(request) {
            // Same-language flow: skip the provider entirely so we don't ask
            // Apple to translate English→English (which is unsupported and
            // would throw). The tone adapter still runs below if requested.
            let language = request.sourceLanguage ?? request.targetLanguage
            result = TranslationResult(
                originalText: request.text,
                translatedText: request.text,
                sourceLanguage: language,
                targetLanguage: request.targetLanguage,
                providerIdentifier: "passthrough",
                adapterIdentifier: nil,
                durationMs: 0
            )
        } else {
            result = try await provider.translate(
                request.text,
                from: request.sourceLanguage,
                to: request.targetLanguage
            )
        }

        guard request.tone != .neutral else { return result }

        do {
            let adapted = try await toneAdapter.adapt(
                result.translatedText,
                tone: request.tone,
                language: request.targetLanguage
            )
            result = result.withAdaptedText(adapted, adapterIdentifier: toneAdapter.identifier)
        } catch let error as TranslationError {
            throw error
        } catch {
            throw TranslationError.adapterFailed(underlying: error)
        }

        return result
    }

    public func prewarm() async {
        await provider.prewarm()
        await toneAdapter.prewarm()
        await voiceProvider?.prewarm()
    }

    /// True when the user is asking for "polish this text in tone X" rather
    /// than a cross-language translation. Only triggers when source is
    /// explicitly set to the same language as target — auto-detect always
    /// goes through the provider.
    private func isSameLanguageRequest(_ request: TranslationRequest) -> Bool {
        guard let source = request.sourceLanguage else { return false }
        return source.code == request.targetLanguage.code
    }
}
