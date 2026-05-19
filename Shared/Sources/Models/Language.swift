import Foundation

/// A language the translation pipeline can speak.
public struct Language: Hashable, Codable, Sendable {
    public let code: String
    public let displayName: String
    public let nativeName: String
    public let flag: String

    public init(code: String, displayName: String, nativeName: String, flag: String) {
        self.code = code
        self.displayName = displayName
        self.nativeName = nativeName
        self.flag = flag
    }
}

public extension Language {
    static let english     = Language(code: "en",      displayName: "English",    nativeName: "English",    flag: "🇺🇸")
    static let russian     = Language(code: "ru",      displayName: "Russian",    nativeName: "Русский",    flag: "🇷🇺")
    static let spanish     = Language(code: "es",      displayName: "Spanish",    nativeName: "Español",    flag: "🇪🇸")
    static let french      = Language(code: "fr",      displayName: "French",     nativeName: "Français",   flag: "🇫🇷")
    static let german      = Language(code: "de",      displayName: "German",     nativeName: "Deutsch",    flag: "🇩🇪")
    static let italian     = Language(code: "it",      displayName: "Italian",    nativeName: "Italiano",   flag: "🇮🇹")
    static let portuguese  = Language(code: "pt",      displayName: "Portuguese", nativeName: "Português",  flag: "🇵🇹")
    static let chinese     = Language(code: "zh-Hans", displayName: "Chinese",    nativeName: "中文",        flag: "🇨🇳")
    static let japanese    = Language(code: "ja",      displayName: "Japanese",   nativeName: "日本語",      flag: "🇯🇵")
    static let korean      = Language(code: "ko",      displayName: "Korean",     nativeName: "한국어",      flag: "🇰🇷")
    static let arabic      = Language(code: "ar",      displayName: "Arabic",     nativeName: "العربية",     flag: "🇸🇦")
    static let hindi       = Language(code: "hi",      displayName: "Hindi",      nativeName: "हिन्दी",       flag: "🇮🇳")
    static let turkish     = Language(code: "tr",      displayName: "Turkish",    nativeName: "Türkçe",     flag: "🇹🇷")
    static let polish      = Language(code: "pl",      displayName: "Polish",     nativeName: "Polski",     flag: "🇵🇱")
    static let dutch       = Language(code: "nl",      displayName: "Dutch",      nativeName: "Nederlands", flag: "🇳🇱")
    static let ukrainian   = Language(code: "uk",      displayName: "Ukrainian",  nativeName: "Українська", flag: "🇺🇦")

    /// Curated set used by the UI pickers. Order matters for display.
    static let allPresets: [Language] = [
        .english, .russian, .spanish, .french, .german, .italian,
        .portuguese, .chinese, .japanese, .korean, .arabic, .hindi,
        .turkish, .polish, .dutch, .ukrainian
    ]

    static func preset(for code: String) -> Language? {
        allPresets.first { $0.code == code }
    }
}
