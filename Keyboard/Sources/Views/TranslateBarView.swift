import SwiftUI
import TranslationKeyboardShared

/// Top strip: language pair (tappable to change source/target), tone picker,
/// and the Translate button.
struct TranslateBarView: View {
    @ObservedObject var coordinator: KeyboardCoordinator
    let onTranslate: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                sourceMenu
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                targetMenu
                Spacer(minLength: 4)
                tonePicker
                translateButton
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            errorBanner
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(uiColor: .separator))
                .frame(height: 0.5)
        }
    }

    // MARK: Language pickers

    private var sourceMenu: some View {
        Menu {
            Button {
                coordinator.updateSource(nil)
            } label: {
                Label("Auto-detect", systemImage: coordinator.settings.sourceLanguage == nil ? "checkmark" : "globe")
            }
            Divider()
            ForEach(Language.allPresets, id: \.code) { lang in
                Button {
                    coordinator.updateSource(lang)
                } label: {
                    HStack {
                        Text("\(lang.flag) \(lang.displayName)")
                        if coordinator.settings.sourceLanguage?.code == lang.code {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            languageChip(
                flag: coordinator.settings.sourceLanguage?.flag ?? "🌐",
                title: coordinator.settings.sourceLanguage?.displayName ?? "Auto"
            )
        }
    }

    private var targetMenu: some View {
        Menu {
            ForEach(Language.allPresets, id: \.code) { lang in
                Button {
                    coordinator.updateTarget(lang)
                } label: {
                    HStack {
                        Text("\(lang.flag) \(lang.displayName)")
                        if coordinator.settings.targetLanguage.code == lang.code {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            languageChip(
                flag: coordinator.settings.targetLanguage.flag,
                title: coordinator.settings.targetLanguage.displayName
            )
        }
    }

    private func languageChip(flag: String, title: String) -> some View {
        HStack(spacing: 4) {
            Text(flag)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(uiColor: .systemBackground), in: Capsule())
        .foregroundStyle(Color(uiColor: .label))
    }

    // MARK: Tone

    private var tonePicker: some View {
        Menu {
            ForEach(Tone.allCases, id: \.self) { tone in
                Button {
                    coordinator.updateTone(tone)
                } label: {
                    Label(tone.displayName, systemImage: tone.symbol)
                }
            }
        } label: {
            Image(systemName: coordinator.settings.tone.symbol)
                .font(.system(size: 13))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(uiColor: .systemBackground), in: Capsule())
                .foregroundStyle(Color(uiColor: .label))
        }
    }

    // MARK: Translate

    private var translateButton: some View {
        Button(action: onTranslate) {
            HStack(spacing: 6) {
                if coordinator.phase == .translating {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                Text("Translate")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor, in: Capsule())
        }
        .disabled(coordinator.phase == .translating)
    }

    // MARK: Error banner

    @ViewBuilder
    private var errorBanner: some View {
        if case .error(let message) = coordinator.phase {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Spacer()
                Button("Retry") { onTranslate() }
                    .font(.system(size: 12, weight: .semibold))
                Button {
                    coordinator.clearError()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.orange.opacity(0.15))
        }
    }
}
