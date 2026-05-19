import XCTest
@testable import TranslationKeyboardShared

final class TranslationPipelineTests: XCTestCase {

    func test_neutralTone_skipsAdapter() async throws {
        let provider = MockTranslationProvider(prefix: "[t]")
        let adapter = MockToneAdapter()
        let pipeline = TranslationPipeline(provider: provider, toneAdapter: adapter)

        let result = try await pipeline.process(
            TranslationRequest(text: "Hola", targetLanguage: .english, tone: .neutral)
        )

        XCTAssertEqual(result.translatedText, "[t] en: Hola")
        XCTAssertNil(result.adapterIdentifier, "Adapter should not run for neutral tone")
    }

    func test_nonNeutralTone_runsAdapter() async throws {
        let provider = MockTranslationProvider(prefix: "[t]")
        let adapter = MockToneAdapter()
        let pipeline = TranslationPipeline(provider: provider, toneAdapter: adapter)

        let result = try await pipeline.process(
            TranslationRequest(text: "Hola", targetLanguage: .english, tone: .formal)
        )

        XCTAssertEqual(result.translatedText, "[formal] [t] en: Hola")
        XCTAssertEqual(result.adapterIdentifier, "mock_tone")
    }

    func test_providerFailure_propagates() async {
        let provider = MockTranslationProvider(shouldFail: .timeout)
        let adapter = MockToneAdapter()
        let pipeline = TranslationPipeline(provider: provider, toneAdapter: adapter)

        do {
            _ = try await pipeline.process(
                TranslationRequest(text: "Hola", targetLanguage: .english, tone: .neutral)
            )
            XCTFail("Expected provider timeout to throw")
        } catch let error as TranslationError {
            if case .timeout = error { return }
            XCTFail("Expected .timeout, got \(error)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_adapterFailure_wrappedAsAdapterFailed() async {
        let provider = MockTranslationProvider()
        struct Boom: Error {}
        let adapter = MockToneAdapter(shouldFail: Boom())
        let pipeline = TranslationPipeline(provider: provider, toneAdapter: adapter)

        do {
            _ = try await pipeline.process(
                TranslationRequest(text: "Hola", targetLanguage: .english, tone: .casual)
            )
            XCTFail("Expected adapter failure")
        } catch let error as TranslationError {
            if case .adapterFailed = error { return }
            XCTFail("Expected .adapterFailed, got \(error)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_emptyInput_throwsInvalidInput() async {
        let pipeline = TranslationPipeline(
            provider: MockTranslationProvider(),
            toneAdapter: NoOpToneAdapter()
        )

        do {
            _ = try await pipeline.process(
                TranslationRequest(text: "   ", targetLanguage: .english, tone: .neutral)
            )
            XCTFail("Expected invalidInput for empty text")
        } catch let error as TranslationError {
            if case .invalidInput = error { return }
            XCTFail("Expected .invalidInput, got \(error)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_noOpAdapter_returnsInputUnchanged() async throws {
        let adapter = NoOpToneAdapter()
        let out = try await adapter.adapt("hi", tone: .formal, language: .english)
        XCTAssertEqual(out, "hi")
    }

    func test_sameLanguageRequest_skipsProvider() async throws {
        // Provider configured to throw — proves pipeline doesn't reach it
        // when source == target.
        let provider = MockTranslationProvider(shouldFail: .timeout)
        let adapter = MockToneAdapter()
        let pipeline = TranslationPipeline(provider: provider, toneAdapter: adapter)

        let result = try await pipeline.process(
            TranslationRequest(
                text: "Hello team",
                sourceLanguage: .english,
                targetLanguage: .english,
                tone: .business
            )
        )

        XCTAssertEqual(result.translatedText, "[business] Hello team")
        XCTAssertEqual(result.providerIdentifier, "passthrough")
        XCTAssertEqual(result.adapterIdentifier, "mock_tone")
    }

    func test_sameLanguageRequest_neutralTone_returnsInputUnchanged() async throws {
        let pipeline = TranslationPipeline(
            provider: MockTranslationProvider(shouldFail: .timeout),
            toneAdapter: NoOpToneAdapter()
        )
        let result = try await pipeline.process(
            TranslationRequest(
                text: "Hello",
                sourceLanguage: .english,
                targetLanguage: .english,
                tone: .neutral
            )
        )
        XCTAssertEqual(result.translatedText, "Hello")
        XCTAssertEqual(result.providerIdentifier, "passthrough")
    }
}
