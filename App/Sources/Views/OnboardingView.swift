import SwiftUI
import TranslationKeyboardShared

struct OnboardingView: View {
    let onDone: () -> Void
    @State private var page = 0
    @EnvironmentObject private var prefs: UserPreferences

    var body: some View {
        TabView(selection: $page) {
            pitch.tag(0)
            setup.tag(1)
            languagePick.tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Color(uiColor: .systemBackground))
    }

    private var pitch: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "character.bubble.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            Text("Type, tap, translate.")
                .font(.largeTitle).bold()
            Text("Write in your language, tap Translate, your message becomes English (or any of 16 languages).")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Spacer()
            Button("Continue") { page = 1 }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom, 40)
        }
        .padding()
    }

    private var setup: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "keyboard")
                .font(.system(size: 70))
                .foregroundStyle(.tint)
            Text("Enable the keyboard")
                .font(.title).bold()
            VStack(alignment: .leading, spacing: 10) {
                step("1.", "Open iOS Settings → General → Keyboard → Keyboards")
                step("2.", "Tap “Add New Keyboard…” and pick Yet Another Translate Keyboard")
                step("3.", "Tap Yet Another Translate Keyboard and turn on “Allow Full Access”")
                step("4.", "Long-press 🌐 in any app to switch to Yet Another Translate Keyboard")
            }
            .padding(.horizontal, 24)
            Spacer()
            Button("Next") { page = 2 }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom, 40)
        }
        .padding()
    }

    private var languagePick: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "globe")
                .font(.system(size: 70))
                .foregroundStyle(.tint)
            Text("Pick a target language")
                .font(.title).bold()
            Picker("Target", selection: $prefs.settings.targetLanguage) {
                ForEach(Language.allPresets, id: \.code) { lang in
                    Text("\(lang.flag) \(lang.displayName)").tag(lang)
                }
            }
            .pickerStyle(.wheel)
            Spacer()
            Button("Get started") { onDone() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom, 40)
        }
        .padding()
    }

    private func step(_ index: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(index).bold()
            Text(text)
        }
    }
}
