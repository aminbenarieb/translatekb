import Foundation
import SwiftUI
import Combine
import TranslationKeyboardShared

/// SwiftUI-friendly wrapper around `AppGroupStorage` so settings views can bind
/// directly with `@Published` semantics.
@MainActor
final class UserPreferences: ObservableObject {
    private let storage: AppGroupStorage

    @Published var settings: TranslationSettings {
        didSet {
            guard settings != oldValue else { return }
            storage.saveSettings(settings)
        }
    }

    @Published var usageCount: Int

    init(storage: AppGroupStorage = .shared) {
        self.storage = storage
        self.settings = storage.loadSettings()
        self.usageCount = storage.usageCount
    }

    func refreshUsage() {
        usageCount = storage.usageCount
    }
}
