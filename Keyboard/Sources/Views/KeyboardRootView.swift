import SwiftUI
import TranslationKeyboardShared

/// Top-level SwiftUI view hosted inside `KeyboardViewController`.
struct KeyboardRootView: View {
    @ObservedObject var coordinator: KeyboardCoordinator
    let onCharacter: (Character) -> Void
    let onBackspace: () -> Void
    let onSpace: () -> Void
    let onReturn: () -> Void
    let onShift: () -> Void
    let onNextInputMode: () -> Void
    let onTranslate: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TranslateBarView(coordinator: coordinator, onTranslate: onTranslate)
            KeyboardLayoutView(
                layout: coordinator.activeLayout,
                onCharacter: onCharacter,
                onBackspace: onBackspace,
                onSpace: onSpace,
                onReturn: onReturn,
                onShift: onShift,
                onNextInputMode: onNextInputMode,
                shiftEnabled: coordinator.shiftEnabled,
                capsLocked: coordinator.capsLocked
            )
            .background(Color(uiColor: .tertiarySystemBackground))
            .overlay(alignment: .topTrailing) {
                if #available(iOS 18.0, *) {
                    sessionHost
                }
            }
        }
        .background(Color(uiColor: .tertiarySystemBackground))
    }

    @available(iOS 18.0, *)
    @ViewBuilder
    private var sessionHost: some View {
        if let bridge = coordinator.bridgeProviderBox.value as? AppleTranslationSessionBridge {
            AppleTranslationSessionHost(bridge: bridge)
        }
    }
}
