import SwiftUI
import TranslationKeyboardShared

struct RootView: View {
    @EnvironmentObject private var prefs: UserPreferences
    @State private var showOnboarding: Bool = Self.initialOnboardingState()

    private static func initialOnboardingState() -> Bool {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--skip-onboarding") {
            return false
        }
        #endif
        return !AppGroupStorage.shared.hasOnboarded
    }

    var body: some View {
        SettingsView()
            .sheet(isPresented: $showOnboarding) {
                OnboardingView {
                    AppGroupStorage.shared.hasOnboarded = true
                    showOnboarding = false
                }
                .interactiveDismissDisabled()
            }
    }
}
