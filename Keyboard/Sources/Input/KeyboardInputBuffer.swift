import Foundation
import UIKit

/// Reads and rewrites the text currently in the host app's text field via the
/// `UITextDocumentProxy`. Used by the Translate flow.
public struct KeyboardInputBuffer {
    public let proxy: UITextDocumentProxy

    public init(proxy: UITextDocumentProxy) {
        self.proxy = proxy
    }

    /// Best-effort capture of the current text.
    ///
    /// If the user has selected text, that's the draft. Otherwise we combine
    /// the before- and after-cursor contexts so a freshly-pasted message is
    /// captured even when the cursor sits in the middle.
    ///
    /// After a paste, `documentContextBeforeInput` can briefly return `nil`
    /// because the proxy hasn't been notified of the change yet. We nudge it
    /// with a zero-offset `adjustTextPosition` first — a known workaround that
    /// forces UIKit to refresh the proxy's cached context.
    public func currentDraft() -> String {
        proxy.adjustTextPosition(byCharacterOffset: 0)

        if let selected = proxy.selectedText, !selected.isEmpty {
            return selected
        }
        let before = proxy.documentContextBeforeInput ?? ""
        let after = proxy.documentContextAfterInput ?? ""
        return before + after
    }

    /// Replace whatever `currentDraft()` returned with `replacement`. Handles
    /// both the "user selected text" case and the "translate everything around
    /// the cursor" case.
    public func replaceDraft(with replacement: String) {
        proxy.adjustTextPosition(byCharacterOffset: 0)

        if let selected = proxy.selectedText, !selected.isEmpty {
            // insertText overwrites the selection in one shot.
            proxy.insertText(replacement)
            return
        }

        // Move the cursor to the end of the field so deleteBackward catches
        // anything after the cursor too.
        let after = proxy.documentContextAfterInput ?? ""
        if !after.isEmpty {
            proxy.adjustTextPosition(byCharacterOffset: after.count)
        }

        let before = proxy.documentContextBeforeInput ?? ""
        let toDelete = before.count + after.count
        for _ in 0..<toDelete {
            proxy.deleteBackward()
        }
        proxy.insertText(replacement)
    }

    public func insert(_ text: String) {
        proxy.insertText(text)
    }

    public func deleteBackward() {
        proxy.deleteBackward()
    }
}
