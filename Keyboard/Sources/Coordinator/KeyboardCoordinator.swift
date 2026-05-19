import Foundation
import Combine
import os
import TranslationKeyboardShared

/// Drives the keyboard UI: owns the pipeline, holds current settings, and
/// publishes translate state changes to SwiftUI views.
@MainActor
public final class KeyboardCoordinator: ObservableObject {

    public enum Phase: Equatable {
        case idle
        case translating
        case error(String)
    }

    @Published public private(set) var phase: Phase = .idle
    @Published public var settings: TranslationSettings {
        didSet { layoutOverride = nil }
    }
    @Published public var shiftEnabled: Bool = true
    @Published public var capsLocked: Bool = false
    /// When non-nil, takes priority over the source-language-derived layout.
    /// Lets the user explicitly pick a layout via the keyboard's globe button.
    @Published public var layoutOverride: KeyboardLayout? = nil

    public var activeLayout: KeyboardLayout {
        layoutOverride ?? KeyboardLayout.forSource(settings.sourceLanguage)
    }

    public let bridgeProviderBox = BridgeProviderBox()

    private let storage: AppGroupStorage
    private let usage: UsageCounter
    private let logger = Logger(subsystem: "com.aminbenarieb.translatekeyboard", category: "coordinator")
    private lazy var pipeline: TranslationPipeline = {
        let provider = AppleTranslationProvider { [bridgeProviderBox] in
            bridgeProviderBox.value
        }
        return TranslationPipeline(provider: provider, toneAdapter: NoOpToneAdapter())
    }()

    public func setError(_ message: String) {
        phase = .error(message)
    }

    public init(
        storage: AppGroupStorage = .shared,
        usage: UsageCounter? = nil
    ) {
        self.storage = storage
        self.usage = usage ?? UsageCounter(storage: storage)
        self.settings = storage.loadSettings()
    }

    public func translate(text: String) async -> String? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            phase = .error("Type something first")
            return nil
        }

        phase = .translating
        let request = TranslationRequest(
            text: text,
            sourceLanguage: settings.sourceLanguage,
            targetLanguage: settings.targetLanguage,
            tone: settings.tone
        )

        do {
            let result = try await pipeline.process(request)
            usage.increment(provider: pipeline.providerIdentifier)
            phase = .idle
            return result.translatedText
        } catch let error as TranslationError {
            logger.error("translate failed: \(error.localizedDescription, privacy: .public)")
            phase = .error(error.errorDescription ?? "Translation failed")
            return nil
        } catch {
            logger.error("translate failed: \(error.localizedDescription, privacy: .public)")
            phase = .error("Translation failed")
            return nil
        }
    }

    public func updateTone(_ tone: Tone) {
        settings.tone = tone
        storage.saveSettings(settings)
    }

    public func updateSource(_ language: Language?) {
        settings.sourceLanguage = language
        storage.saveSettings(settings)
    }

    public func updateTarget(_ language: Language) {
        settings.targetLanguage = language
        storage.saveSettings(settings)
    }

    public func reloadSettings() {
        settings = storage.loadSettings()
    }

    public func clearError() {
        if case .error = phase { phase = .idle }
    }

    public func setLayoutOverride(_ layout: KeyboardLayout?) {
        layoutOverride = layout
    }
}

/// Holds a reference to the iOS-18+ session bridge so the provider closure can
/// resolve it lazily without the shared module depending on SwiftUI/iOS 18.
public final class BridgeProviderBox: @unchecked Sendable {
    public var value: AnyObject?
    public init() {}
}
