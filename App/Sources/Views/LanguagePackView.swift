import SwiftUI
import TranslationKeyboardShared
#if canImport(Translation)
import Translation
#endif

/// Shows installed / download-on-use status for each curated source language
/// against the user's currently selected target language. Lets the user trigger
/// a pre-download via `TranslationSession.prepareTranslation()`.
struct LanguagePackView: View {
    @EnvironmentObject private var prefs: UserPreferences

    enum Status {
        case installed
        case supported
        case unsupported
        case sameLanguage
        case unknown

        var label: String {
            switch self {
            case .installed:    return "Installed"
            case .supported:    return "Not downloaded"
            case .unsupported:  return "Unsupported pair"
            case .sameLanguage: return "Same as target"
            case .unknown:      return "—"
            }
        }

        var color: Color {
            switch self {
            case .installed:    return .green
            case .supported:    return .secondary
            case .unsupported:  return .orange
            case .sameLanguage: return .secondary
            case .unknown:      return .secondary
            }
        }
    }

    @State private var statuses: [String: Status] = [:]
    @State private var downloading: Set<String> = []
    @StateObject private var bridgeHolder = LanguagePackBridgeHolder()

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("Pair direction:").font(.footnote).foregroundStyle(.secondary)
                        Text("any → \(prefs.settings.targetLanguage.flag) \(prefs.settings.targetLanguage.displayName)")
                            .font(.footnote.bold())
                    }
                    Text("Apple downloads language packs on first use. Tap a row to pre-download. Pull to refresh status.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Section("Languages") {
                ForEach(visibleLanguages, id: \.code) { lang in
                    row(for: lang)
                }
            }
        }
        .navigationTitle("Language packs")
        .navigationBarTitleDisplayMode(.inline)
        .background {
            if #available(iOS 18.0, *) {
                bridgeHolder.hostView
            }
        }
        .refreshable { await loadStatuses() }
        .task(id: prefs.settings.targetLanguage.code) { await loadStatuses() }
    }

    private var visibleLanguages: [Language] {
        Language.allPresets.filter { $0.code != prefs.settings.targetLanguage.code }
    }

    @ViewBuilder
    private func row(for lang: Language) -> some View {
        let status = statuses[lang.code] ?? .unknown
        let isDownloading = downloading.contains(lang.code)

        HStack {
            Text("\(lang.flag) \(lang.displayName)")
            Spacer()
            if isDownloading {
                ProgressView().controlSize(.small)
            } else if status == .supported {
                Button("Download") {
                    Task { await download(lang) }
                }
                .buttonStyle(.borderless)
                .font(.footnote.bold())
            } else {
                Text(status.label)
                    .font(.caption)
                    .foregroundStyle(status.color)
            }
        }
    }

    private func loadStatuses() async {
        guard #available(iOS 18.0, *) else {
            await MainActor.run {
                statuses = Dictionary(uniqueKeysWithValues: Language.allPresets.map { ($0.code, .unknown) })
            }
            return
        }
        var next: [String: Status] = [:]
        let availability = LanguageAvailability()
        let target = Locale.Language(identifier: prefs.settings.targetLanguage.code)
        for lang in Language.allPresets {
            if lang.code == prefs.settings.targetLanguage.code {
                next[lang.code] = .sameLanguage
                continue
            }
            let source = Locale.Language(identifier: lang.code)
            let status = await availability.status(from: source, to: target)
            switch status {
            case .installed:    next[lang.code] = .installed
            case .supported:    next[lang.code] = .supported
            case .unsupported:  next[lang.code] = .unsupported
            @unknown default:   next[lang.code] = .unknown
            }
        }
        await MainActor.run { statuses = next }
    }

    private func download(_ lang: Language) async {
        guard #available(iOS 18.0, *), let bridge = bridgeHolder.bridge as? AppleTranslationSessionBridge else {
            return
        }
        downloading.insert(lang.code)
        defer { downloading.remove(lang.code) }

        do {
            let source = Locale.Language(identifier: lang.code)
            let target = Locale.Language(identifier: prefs.settings.targetLanguage.code)
            let session = try await bridge.session(source: source, target: target)
            try await session.prepareTranslation()
            await loadStatuses()
        } catch {
            // Surface the error in status; refresh shows the real result.
            await loadStatuses()
        }
    }
}

/// Owns an iOS-18 bridge for this screen so we can call `prepareTranslation()`.
@MainActor
private final class LanguagePackBridgeHolder: ObservableObject {
    private var _bridge: AnyObject?

    var bridge: AnyObject? {
        if #available(iOS 18.0, *) {
            if _bridge == nil { _bridge = AppleTranslationSessionBridge() }
            return _bridge
        }
        return nil
    }

    @ViewBuilder
    var hostView: some View {
        if #available(iOS 18.0, *), let b = bridge as? AppleTranslationSessionBridge {
            AppleTranslationSessionHost(bridge: b)
        }
    }
}
