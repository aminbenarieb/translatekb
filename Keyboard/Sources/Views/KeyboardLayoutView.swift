import SwiftUI

/// Renders the active `KeyboardLayout`. Letter rows come from the layout
/// (QWERTY, ЙЦУКЕН, …); shift, backspace, space, return, globe, and the
/// numeric switcher are layout-agnostic.
struct KeyboardLayoutView: View {
    let layout: KeyboardLayout
    let onCharacter: (Character) -> Void
    let onBackspace: () -> Void
    let onSpace: () -> Void
    let onReturn: () -> Void
    let onShift: () -> Void
    let onNextInputMode: () -> Void
    let shiftEnabled: Bool
    let capsLocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            keyRow(layout.row1)
            if layout.row2NeedsSidePadding {
                HStack(spacing: 4) {
                    Spacer(minLength: 12)
                    keyRow(layout.row2)
                    Spacer(minLength: 12)
                }
            } else {
                keyRow(layout.row2)
            }
            HStack(spacing: 4) {
                KeyView(
                    label: "",
                    symbol: capsLocked ? "capslock.fill" : (shiftEnabled ? "shift.fill" : "shift"),
                    style: .utility,
                    action: onShift
                )
                .frame(width: 40)
                keyRow(layout.row3)
                KeyView(
                    label: "",
                    symbol: "delete.left",
                    style: .utility,
                    action: onBackspace
                )
                .frame(width: 40)
            }
            HStack(spacing: 4) {
                KeyView(label: "123", style: .utility, action: {})
                    .frame(width: 50)
                KeyView(label: "", symbol: "globe", style: .utility, action: onNextInputMode)
                    .frame(width: 40)
                KeyView(label: "space", style: .wide, action: onSpace)
                KeyView(label: "return", style: .utility, action: onReturn)
                    .frame(width: 80)
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 6)
    }

    private func keyRow(_ letters: [String]) -> some View {
        HStack(spacing: 3) {
            ForEach(Array(letters.enumerated()), id: \.offset) { _, ch in
                KeyView(label: displayed(ch)) {
                    let str = displayed(ch)
                    if let c = str.first { onCharacter(c) }
                }
            }
        }
    }

    private func displayed(_ ch: String) -> String {
        let upper = shiftEnabled || capsLocked
        return upper ? ch.uppercased() : ch
    }
}
