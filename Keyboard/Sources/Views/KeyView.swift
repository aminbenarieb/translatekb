import SwiftUI

/// One tappable key. Plays a subtle press animation; the actual character/action
/// is delegated to the parent.
struct KeyView: View {
    enum Style {
        case letter
        case utility
        case wide
        case accent
    }

    let label: String
    let symbol: String?
    let style: Style
    let action: () -> Void

    init(label: String, symbol: String? = nil, style: Style = .letter, action: @escaping () -> Void) {
        self.label = label
        self.symbol = symbol
        self.style = style
        self.action = action
    }

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(background)
                    .shadow(color: .black.opacity(0.18), radius: 0, x: 0, y: 1)
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(foreground)
                } else {
                    Text(label)
                        .font(.system(size: style == .letter ? 22 : 16, weight: .regular))
                        .foregroundStyle(foreground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .scaleEffect(pressed ? 0.96 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }

    private var background: Color {
        switch style {
        case .letter:  return Color(uiColor: .systemBackground)
        case .utility: return Color(uiColor: .secondarySystemBackground)
        case .wide:    return Color(uiColor: .systemBackground)
        case .accent:  return Color.accentColor
        }
    }

    private var foreground: Color {
        switch style {
        case .accent: return .white
        default: return Color(uiColor: .label)
        }
    }
}
