import SwiftUI
import TranslationKeyboardShared

@main
struct TranslationKeyboardApp: App {
    @StateObject private var prefs = UserPreferences()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(prefs)
        }
    }
}
