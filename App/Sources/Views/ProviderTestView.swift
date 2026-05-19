import SwiftUI
import TranslationKeyboardShared
#if canImport(Translation)
import Translation
#endif

/// Dev-only screen to A/B test providers and tone adapters. Hidden behind 5
/// taps on the version label in Settings.
struct ProviderTestView: View {
    @EnvironmentObject private var prefs: UserPreferences
    @State private var input: String = "Привет, как дела?"
    @State private var output: String = ""
    @State private var duration: Int = 0
    @State private var providerName: String = "—"
    @State private var isRunning = false
    @State private var error: String?

    @State private var providerKey: ProviderKey = .apple
    @State private var adapterKey: AdapterKey = .noop

    @StateObject private var bridgeHolder = BridgeHolder()

    var body: some View {
        Form {
            Section("Input") {
                TextField("Type some text…", text: $input, axis: .vertical)
                    .lineLimit(3...6)
            }
            Section("Pipeline") {
                Picker("Provider", selection: $providerKey) {
                    ForEach(ProviderKey.allCases, id: \.self) { k in
                        Text(k.label).tag(k)
                    }
                }
                Picker("Adapter", selection: $adapterKey) {
                    ForEach(AdapterKey.allCases, id: \.self) { k in
                        Text(k.label).tag(k)
                    }
                }
                LabeledContent("Tone", value: prefs.settings.tone.displayName)
                LabeledContent("Target", value: prefs.settings.targetLanguage.displayName)
            }
            Section("Result") {
                Text(output.isEmpty ? "—" : output)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                LabeledContent("Provider", value: providerName)
                LabeledContent("Duration", value: "\(duration) ms")
                if let error {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            Section {
                Button {
                    Task { await run() }
                } label: {
                    HStack {
                        if isRunning { ProgressView().controlSize(.small) }
                        Text(isRunning ? "Translating…" : "Translate")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isRunning || input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Provider test")
        .navigationBarTitleDisplayMode(.inline)
        .background {
            if #available(iOS 18.0, *) {
                bridgeHolder.hostView
            }
        }
    }

    @MainActor
    private func run() async {
        error = nil
        output = ""
        isRunning = true
        defer { isRunning = false }

        let provider = makeProvider()
        let adapter = makeAdapter()
        let pipeline = TranslationPipeline(provider: provider, toneAdapter: adapter)
        let request = TranslationRequest(
            text: input,
            sourceLanguage: prefs.settings.sourceLanguage,
            targetLanguage: prefs.settings.targetLanguage,
            tone: prefs.settings.tone
        )
        do {
            let result = try await pipeline.process(request)
            output = result.translatedText
            duration = result.durationMs
            providerName = result.providerIdentifier
        } catch let e as TranslationKeyboardShared.TranslationError {
            error = e.errorDescription ?? "Failed"
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func makeProvider() -> TranslationProvider {
        switch providerKey {
        case .apple:
            return AppleTranslationProvider { [bridgeHolder] in
                if #available(iOS 18.0, *) {
                    return await bridgeHolder.bridge
                }
                return nil
            }
        case .mock:
            return MockTranslationProvider(prefix: "[mock]")
        case .cloud:
            return CloudTranslationProvider()
        }
    }

    private func makeAdapter() -> ToneAdapter {
        switch adapterKey {
        case .noop:  return NoOpToneAdapter()
        case .mock:  return MockToneAdapter()
        case .cloud: return CloudLLMToneAdapter()
        }
    }

    enum ProviderKey: String, CaseIterable {
        case apple, mock, cloud
        var label: String {
            switch self {
            case .apple: return "Apple"
            case .mock:  return "Mock"
            case .cloud: return "Cloud (stub)"
            }
        }
    }

    enum AdapterKey: String, CaseIterable {
        case noop, mock, cloud
        var label: String {
            switch self {
            case .noop:  return "NoOp"
            case .mock:  return "Mock"
            case .cloud: return "Cloud LLM (stub)"
            }
        }
    }
}

/// Lazily creates the iOS-18 bridge so we can keep the @available scoping local.
@MainActor
private final class BridgeHolder: ObservableObject {
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
