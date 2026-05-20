import XCTest
@testable import TranslationKeyboardShared

final class VoiceProviderTests: XCTestCase {

    func test_appleSpeechProvider_isUnavailableInV1() async {
        let provider = AppleSpeechVoiceProvider()
        let available = await provider.isAvailable()
        XCTAssertFalse(available, "Apple Speech provider must report unavailable in v0.2 — implementation is v2 work")
    }

    func test_appleSpeechProvider_transcribeThrowsProviderUnavailable() async {
        let provider = AppleSpeechVoiceProvider()
        let buffer = AudioBuffer(samples: Data(), sampleRate: 16_000)
        do {
            _ = try await provider.transcribe(audio: buffer, language: .english)
            XCTFail("Expected providerUnavailable")
        } catch let error as TranslationError {
            if case .providerUnavailable = error { return }
            XCTFail("Wrong case: \(error)")
        } catch {
            XCTFail("Unexpected: \(error)")
        }
    }

    func test_pipeline_voiceAvailable_falseWhenNoVoiceProvider() async {
        let pipeline = TranslationPipeline(
            provider: MockTranslationProvider(),
            toneAdapter: NoOpToneAdapter()
        )
        let available = await pipeline.voiceAvailable()
        XCTAssertFalse(available)
        XCTAssertNil(pipeline.voiceIdentifier)
    }

    func test_pipeline_voiceAvailable_trueWhenMockVoiceWired() async {
        let pipeline = TranslationPipeline(
            provider: MockTranslationProvider(),
            toneAdapter: NoOpToneAdapter(),
            voiceProvider: MockVoiceProvider()
        )
        let available = await pipeline.voiceAvailable()
        XCTAssertTrue(available)
        XCTAssertEqual(pipeline.voiceIdentifier, "mock_voice")
    }

    func test_pipeline_processVoice_transcribesAndTranslates() async throws {
        let pipeline = TranslationPipeline(
            provider: MockTranslationProvider(prefix: "[t]"),
            toneAdapter: NoOpToneAdapter(),
            voiceProvider: MockVoiceProvider(cannedResponse: "Привет")
        )
        let buffer = AudioBuffer(samples: Data(), sampleRate: 16_000)
        let result = try await pipeline.processVoice(buffer, from: .russian, to: .english)
        XCTAssertEqual(result.translatedText, "[t] en: Привет")
    }

    func test_pipeline_processVoice_throwsWhenVoiceUnavailable() async {
        let pipeline = TranslationPipeline(
            provider: MockTranslationProvider(),
            toneAdapter: NoOpToneAdapter(),
            voiceProvider: AppleSpeechVoiceProvider() // stub returns unavailable
        )
        do {
            _ = try await pipeline.processVoice(
                AudioBuffer(samples: Data(), sampleRate: 16_000),
                from: .russian,
                to: .english
            )
            XCTFail("Expected providerUnavailable")
        } catch let error as TranslationError {
            if case .providerUnavailable = error { return }
            XCTFail("Wrong: \(error)")
        } catch {
            XCTFail("Unexpected: \(error)")
        }
    }
}
