import SwiftUI

struct KeyboardSetupView: View {
    var body: some View {
        List {
            Section("Steps") {
                stepRow("1", "Open iOS Settings", "Tap the button below — it deep-links to this app's settings.")
                stepRow("2", "Keyboards → Keyboards", "Inside Settings, go to Keyboards and tap Keyboards again.")
                stepRow("3", "Add New Keyboard…", "Pick TranslateKB from the list of third-party keyboards.")
                stepRow("4", "Allow Full Access", "Tap TranslateKB in the list and enable Allow Full Access. The Translation framework needs network access for language packs.")
                stepRow("5", "Switch in any app", "Long-press 🌐 in any text field to pick TranslateKB.")
            }
            Section {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open iOS Settings", systemImage: "gear")
                }
            }
            Section("Privacy") {
                Text("Full Access lets the keyboard reach the Apple Translation framework, which can download language packs on demand. No text leaves your device.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Setup keyboard")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stepRow(_ index: String, _ title: String, _ subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(index)
                .font(.headline)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
