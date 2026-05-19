import Foundation
import TranslationKeyboardShared

/// Visual key layout for the keyboard. Picked from the user's source language
/// — Russian source → ЙЦУКЕН, English → QWERTY, etc. Scripts we don't have a
/// dedicated layout for fall back to `.qwerty` and the user can paste / use a
/// system keyboard alongside.
public struct KeyboardLayout: Equatable, Sendable {
    public let identifier: String
    public let displayName: String
    public let row1: [String]
    public let row2: [String]
    public let row3: [String]
    public let row2NeedsSidePadding: Bool
    public let isLatinShift: Bool

    public init(
        identifier: String,
        displayName: String,
        row1: [String],
        row2: [String],
        row3: [String],
        row2NeedsSidePadding: Bool = true,
        isLatinShift: Bool = true
    ) {
        self.identifier = identifier
        self.displayName = displayName
        self.row1 = row1
        self.row2 = row2
        self.row3 = row3
        self.row2NeedsSidePadding = row2NeedsSidePadding
        self.isLatinShift = isLatinShift
    }
}

public extension KeyboardLayout {

    /// Standard 10/9/7 QWERTY.
    static let qwerty = KeyboardLayout(
        identifier: "qwerty",
        displayName: "QWERTY",
        row1: "qwertyuiop".map { String($0) },
        row2: "asdfghjkl".map { String($0) },
        row3: "zxcvbnm".map { String($0) }
    )

    /// Russian / Ukrainian ЙЦУКЕН — 12/11/9 keys.
    static let cyrillic = KeyboardLayout(
        identifier: "cyrillic_yctsuken",
        displayName: "ЙЦУКЕН",
        row1: ["й","ц","у","к","е","н","г","ш","щ","з","х","ъ"],
        row2: ["ф","ы","в","а","п","р","о","л","д","ж","э"],
        row3: ["я","ч","с","м","и","т","ь","б","ю"],
        row2NeedsSidePadding: false,
        isLatinShift: true
    )

    /// Pick the most appropriate layout for a source language. Falls back to
    /// QWERTY for any script we don't have a dedicated layout for.
    static func forSource(_ language: Language?) -> KeyboardLayout {
        guard let code = language?.code else { return .qwerty }
        switch code {
        case "ru", "uk":
            return .cyrillic
        default:
            return .qwerty
        }
    }
}
