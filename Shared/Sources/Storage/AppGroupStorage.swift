import Foundation
import os

/// Shared UserDefaults backed by the App Group, used by both the main app and
/// the keyboard extension to read/write user preferences and usage counters.
public final class AppGroupStorage: @unchecked Sendable {
    public static let appGroupIdentifier = "group.com.aminbenarieb.translatekeyboard"

    public static let shared = AppGroupStorage()

    private let defaults: UserDefaults
    private let logger = Logger(subsystem: "com.aminbenarieb.translatekeyboard", category: "storage")

    public init(suiteName: String = AppGroupStorage.appGroupIdentifier) {
        if let group = UserDefaults(suiteName: suiteName) {
            self.defaults = group
        } else {
            // App Group entitlement missing or simulator quirk — fall back to standard
            // so the app still launches in development. Real builds must succeed here.
            self.defaults = .standard
        }
    }

    // MARK: Keys

    private enum Key {
        static let sourceLanguage = "defaultSourceLanguage"
        static let targetLanguage = "defaultTargetLanguage"
        static let tone           = "defaultTone"
        static let usageCount     = "usageCount"
        static let usageMonth     = "usageMonthStart"
        static let lastProvider   = "lastUsedProvider"
        static let hasOnboarded   = "hasOnboarded"
    }

    // MARK: Settings

    public func loadSettings() -> TranslationSettings {
        let sourceCode = defaults.string(forKey: Key.sourceLanguage)
        let source = sourceCode.flatMap { Language.preset(for: $0) }
        let targetCode = defaults.string(forKey: Key.targetLanguage) ?? Language.english.code
        let target = Language.preset(for: targetCode) ?? .english
        let toneRaw = defaults.string(forKey: Key.tone) ?? Tone.neutral.rawValue
        let tone = Tone(rawValue: toneRaw) ?? .neutral
        return TranslationSettings(sourceLanguage: source, targetLanguage: target, tone: tone)
    }

    public func saveSettings(_ settings: TranslationSettings) {
        if let source = settings.sourceLanguage {
            defaults.set(source.code, forKey: Key.sourceLanguage)
        } else {
            defaults.removeObject(forKey: Key.sourceLanguage)
        }
        defaults.set(settings.targetLanguage.code, forKey: Key.targetLanguage)
        defaults.set(settings.tone.rawValue, forKey: Key.tone)
    }

    // MARK: Usage counter

    public var usageCount: Int {
        get { defaults.integer(forKey: Key.usageCount) }
        set { defaults.set(newValue, forKey: Key.usageCount) }
    }

    public var usageMonthStart: Date? {
        get { defaults.object(forKey: Key.usageMonth) as? Date }
        set { defaults.set(newValue, forKey: Key.usageMonth) }
    }

    public var lastUsedProvider: String? {
        get { defaults.string(forKey: Key.lastProvider) }
        set { defaults.set(newValue, forKey: Key.lastProvider) }
    }

    // MARK: Onboarding

    public var hasOnboarded: Bool {
        get { defaults.bool(forKey: Key.hasOnboarded) }
        set { defaults.set(newValue, forKey: Key.hasOnboarded) }
    }
}
