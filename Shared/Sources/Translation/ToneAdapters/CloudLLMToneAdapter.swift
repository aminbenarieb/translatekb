import Foundation

/// Placeholder for a future cloud LLM tone adapter (OpenAI/Claude). MVP keeps
/// the architecture in place but always reports unavailable.
public final class CloudLLMToneAdapter: ToneAdapter {
    public let identifier = "cloud_llm_tone_stub"
    public let displayName = "AI Tone (coming soon)"

    public init() {}

    public func isAvailable() async -> Bool { false }

    public func supportedTones() -> [Tone] { [] }

    public func adapt(_ text: String, tone: Tone, language: Language) async throws -> String {
        throw TranslationError.adapterFailed(underlying: TranslationError.providerUnavailable)
    }
}
