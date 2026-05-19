import UIKit
import SwiftUI
import os
import TranslationKeyboardShared

/// Custom keyboard entry point. Owns the SwiftUI host, the input buffer, and
/// kicks off the Translate pipeline on demand.
public final class KeyboardViewController: UIInputViewController {

    private let logger = Logger(subsystem: "com.aminbenarieb.translatekeyboard", category: "keyboard")
    private var coordinator: KeyboardCoordinator!
    private var inputBuffer: KeyboardInputBuffer!
    private var hostingController: UIHostingController<KeyboardRootView>!

    public override func viewDidLoad() {
        super.viewDidLoad()

        coordinator = KeyboardCoordinator()
        if #available(iOS 18.0, *) {
            coordinator.bridgeProviderBox.value = AppleTranslationSessionBridge()
        }
        inputBuffer = KeyboardInputBuffer(proxy: textDocumentProxy)

        let root = KeyboardRootView(
            coordinator: coordinator,
            onCharacter: { [weak self] ch in self?.handleCharacter(ch) },
            onBackspace: { [weak self] in self?.handleBackspace() },
            onSpace: { [weak self] in self?.inputBuffer.insert(" ") },
            onReturn: { [weak self] in self?.inputBuffer.insert("\n") },
            onShift: { [weak self] in self?.handleShift() },
            onNextInputMode: { [weak self] in self?.advanceToNextInputMode() },
            onTranslate: { [weak self] in self?.handleTranslate() }
        )

        let host = UIHostingController(rootView: root)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        addChild(host)
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        host.didMove(toParent: self)
        hostingController = host

        view.heightAnchor.constraint(greaterThanOrEqualToConstant: 280).isActive = true
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator.reloadSettings()
    }

    // MARK: Input

    private func handleCharacter(_ ch: Character) {
        let toInsert: String
        if coordinator.shiftEnabled && !coordinator.capsLocked {
            toInsert = String(ch).uppercased()
            coordinator.shiftEnabled = false
        } else if coordinator.capsLocked {
            toInsert = String(ch).uppercased()
        } else {
            toInsert = String(ch).lowercased()
        }
        inputBuffer.insert(toInsert)
    }

    private func handleBackspace() {
        inputBuffer.deleteBackward()
    }

    private func handleShift() {
        if coordinator.capsLocked {
            coordinator.capsLocked = false
            coordinator.shiftEnabled = false
        } else if coordinator.shiftEnabled {
            // Tap-twice into caps lock.
            coordinator.capsLocked = true
        } else {
            coordinator.shiftEnabled = true
        }
    }

    private func handleTranslate() {
        let draft = inputBuffer.currentDraft()
        guard !draft.isEmpty else {
            coordinator.setError("Type something first")
            return
        }
        Task { @MainActor in
            if let translated = await coordinator.translate(text: draft) {
                inputBuffer.replaceDraft(with: translated)
            }
        }
    }
}
