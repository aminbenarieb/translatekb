import XCTest
@testable import TranslationKeyboardShared

final class MockProviderTests: XCTestCase {

    func test_mockProvider_returnsPrefixedTranslation() async throws {
        let provider = MockTranslationProvider(prefix: "[mock]")
        let result = try await provider.translate("hola", from: .spanish, to: .english)
        XCTAssertEqual(result.translatedText, "[mock] en: hola")
        XCTAssertEqual(result.sourceLanguage, .spanish)
        XCTAssertEqual(result.targetLanguage, .english)
        XCTAssertEqual(result.providerIdentifier, "mock_translation")
    }

    func test_mockProvider_throwsConfiguredError() async {
        let provider = MockTranslationProvider(shouldFail: .rateLimitExceeded)
        do {
            _ = try await provider.translate("x", from: nil, to: .english)
            XCTFail("Expected to throw")
        } catch let error as TranslationError {
            if case .rateLimitExceeded = error { return }
            XCTFail("Wrong case: \(error)")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_usageCounter_incrementsAndRollsOverByMonth() {
        let suite = "test.usage.\(UUID().uuidString)"
        UserDefaults().removePersistentDomain(forName: suite)
        let storage = AppGroupStorage(suiteName: suite)
        let counter = UsageCounter(storage: storage)

        let mar15 = DateComponents(calendar: .init(identifier: .gregorian), year: 2026, month: 3, day: 15).date!
        let apr01 = DateComponents(calendar: .init(identifier: .gregorian), year: 2026, month: 4, day: 1).date!

        XCTAssertEqual(counter.increment(provider: "p", now: mar15), 1)
        XCTAssertEqual(counter.increment(provider: "p", now: mar15), 2)
        XCTAssertEqual(counter.increment(provider: "p", now: apr01), 1, "New month resets counter")
        XCTAssertEqual(counter.currentCount(now: apr01), 1)
    }

    func test_appGroupStorage_roundtripsSettings() {
        let suite = "test.settings.\(UUID().uuidString)"
        UserDefaults().removePersistentDomain(forName: suite)
        let storage = AppGroupStorage(suiteName: suite)

        var settings = storage.loadSettings()
        XCTAssertEqual(settings.targetLanguage, .english)
        XCTAssertNil(settings.sourceLanguage)
        XCTAssertEqual(settings.tone, .neutral)

        settings = TranslationSettings(sourceLanguage: .russian, targetLanguage: .spanish, tone: .formal)
        storage.saveSettings(settings)

        let reloaded = storage.loadSettings()
        XCTAssertEqual(reloaded.sourceLanguage, .russian)
        XCTAssertEqual(reloaded.targetLanguage, .spanish)
        XCTAssertEqual(reloaded.tone, .formal)
    }
}
