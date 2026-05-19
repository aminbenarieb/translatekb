import SwiftUI
import TranslationKeyboardShared

struct SettingsView: View {
    @EnvironmentObject private var prefs: UserPreferences
    @State private var showProviderTest = false
    @State private var versionTaps = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Translate to") {
                    targetLanguagePicker
                }
                Section("From") {
                    sourceLanguagePicker
                }
                Section("Default tone") {
                    tonePicker
                }
                Section("Provider") {
                    HStack {
                        Image(systemName: "applelogo")
                        VStack(alignment: .leading) {
                            Text("Apple Translation").font(.body)
                            Text("On-device, free, no account.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    NavigationLink("Language packs") {
                        LanguagePackView()
                    }
                }
                Section("Keyboard") {
                    NavigationLink("Setup wizard") {
                        KeyboardSetupView()
                    }
                    LabeledContent("Translations this month") {
                        Text("\(prefs.usageCount)")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Text("Version \(version)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .onTapGesture {
                                versionTaps += 1
                                if versionTaps >= 5 {
                                    versionTaps = 0
                                    showProviderTest = true
                                }
                            }
                        Spacer()
                    }
                }
            }
            .navigationTitle("TranslateKB")
            .navigationDestination(isPresented: $showProviderTest) {
                ProviderTestView()
            }
            .onAppear {
                prefs.refreshUsage()
            }
        }
    }

    private var targetLanguagePicker: some View {
        Picker("Target", selection: $prefs.settings.targetLanguage) {
            ForEach(Language.allPresets, id: \.code) { lang in
                Text("\(lang.flag) \(lang.displayName)").tag(lang)
            }
        }
        .pickerStyle(.navigationLink)
    }

    private var sourceLanguagePicker: some View {
        Picker("Source", selection: sourceBinding) {
            Text("Auto-detect").tag(Language?.none)
            ForEach(Language.allPresets, id: \.code) { lang in
                Text("\(lang.flag) \(lang.displayName)").tag(Language?.some(lang))
            }
        }
        .pickerStyle(.navigationLink)
    }

    private var sourceBinding: Binding<Language?> {
        Binding(
            get: { prefs.settings.sourceLanguage },
            set: { prefs.settings.sourceLanguage = $0 }
        )
    }

    private var tonePicker: some View {
        Picker("Tone", selection: $prefs.settings.tone) {
            ForEach(Tone.allCases, id: \.self) { tone in
                Label(tone.displayName, systemImage: tone.symbol).tag(tone)
            }
        }
        .pickerStyle(.inline)
    }

    private var version: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        return "\(v) (\(b))"
    }
}
