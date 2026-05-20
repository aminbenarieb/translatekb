import ProjectDescription

// MARK: - Constants

let bundlePrefix = "com.aminbenarieb.translatekeyboard"
let appBundleId = bundlePrefix
let keyboardBundleId = "\(bundlePrefix).keyboard"
let appGroupId = "group.\(bundlePrefix)"
let teamId = "5P8935L6RT"
let deploymentTargets: DeploymentTargets = .iOS("17.4")
let marketingVersion = "0.1.0"
let buildNumber = "1"

// MARK: - Settings

let baseSettings: SettingsDictionary = [
    "DEVELOPMENT_TEAM": .string(teamId),
    "CODE_SIGN_STYLE": "Automatic",
    "SWIFT_VERSION": "5.9",
    "IPHONEOS_DEPLOYMENT_TARGET": "17.4",
    "TARGETED_DEVICE_FAMILY": "1", // iPhone only for v1
    "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
    "GCC_C_LANGUAGE_STANDARD": "gnu17",
    "CLANG_CXX_LANGUAGE_STANDARD": "gnu++20",
    "MARKETING_VERSION": .string(marketingVersion),
    "CURRENT_PROJECT_VERSION": .string(buildNumber),
    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor"
]

let releaseSettings: SettingsDictionary = [
    "SWIFT_COMPILATION_MODE": "wholemodule",
    "SWIFT_OPTIMIZATION_LEVEL": "-O",
    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
    "ENABLE_NS_ASSERTIONS": "NO"
]

// MARK: - Shared Framework

let sharedTarget = Target.target(
    name: "TranslationKeyboardShared",
    destinations: .iOS,
    product: .framework,
    bundleId: "\(bundlePrefix).shared",
    deploymentTargets: deploymentTargets,
    infoPlist: .default,
    sources: ["Shared/Sources/**"],
    dependencies: [],
    settings: .settings(
        base: baseSettings.merging([
            "BUILD_LIBRARY_FOR_DISTRIBUTION": "NO",
            "DEFINES_MODULE": "YES"
        ])
    )
)

// MARK: - Keyboard Extension

let keyboardTarget = Target.target(
    name: "TranslationKeyboardExt",
    destinations: .iOS,
    product: .appExtension,
    bundleId: keyboardBundleId,
    deploymentTargets: deploymentTargets,
    infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "Yet Another Translate Keyboard",
        "NSExtension": [
            "NSExtensionAttributes": [
                "IsASCIICapable": false,
                "PrefersRightToLeft": false,
                "PrimaryLanguage": "en-US",
                "RequestsOpenAccess": true
            ],
            "NSExtensionPointIdentifier": "com.apple.keyboard-service",
            "NSExtensionPrincipalClass": "$(PRODUCT_MODULE_NAME).KeyboardViewController"
        ]
    ]),
    sources: ["Keyboard/Sources/**"],
    resources: ["Keyboard/Resources/**"],
    entitlements: .file(path: "Keyboard/Entitlements/Keyboard.entitlements"),
    dependencies: [
        .target(name: "TranslationKeyboardShared"),
        .sdk(name: "Translation", type: .framework, status: .required)
    ],
    settings: .settings(base: baseSettings, release: releaseSettings)
)

// MARK: - Main App

let appTarget = Target.target(
    name: "TranslationKeyboard",
    destinations: .iOS,
    product: .app,
    bundleId: appBundleId,
    deploymentTargets: deploymentTargets,
    infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "Yet Another Translate Keyboard",
        "LSApplicationCategoryType": "public.app-category.productivity",
        "UILaunchScreen": [
            "UIColorName": "",
            "UIImageName": ""
        ],
        "UISupportedInterfaceOrientations": [
            "UIInterfaceOrientationPortrait"
        ],
        "ITSAppUsesNonExemptEncryption": false
    ]),
    sources: ["App/Sources/**"],
    resources: ["App/Resources/**"],
    entitlements: .file(path: "App/Entitlements/TranslationKeyboard.entitlements"),
    dependencies: [
        .target(name: "TranslationKeyboardShared"),
        .target(name: "TranslationKeyboardExt"),
        .sdk(name: "Translation", type: .framework, status: .required)
    ],
    settings: .settings(base: baseSettings, release: releaseSettings)
)

// MARK: - Tests

let sharedTestsTarget = Target.target(
    name: "TranslationKeyboardSharedTests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "\(bundlePrefix).shared.tests",
    deploymentTargets: deploymentTargets,
    infoPlist: .default,
    sources: ["Tests/Sources/**"],
    dependencies: [
        .target(name: "TranslationKeyboardShared")
    ],
    settings: .settings(base: baseSettings, release: releaseSettings)
)

// MARK: - Schemes

let appScheme = Scheme.scheme(
    name: "TranslationKeyboard",
    shared: true,
    buildAction: .buildAction(targets: ["TranslationKeyboard"]),
    testAction: .targets(
        ["TranslationKeyboardSharedTests"],
        configuration: .debug
    ),
    runAction: .runAction(configuration: .debug, executable: "TranslationKeyboard"),
    archiveAction: .archiveAction(configuration: .release),
    profileAction: .profileAction(configuration: .release, executable: "TranslationKeyboard"),
    analyzeAction: .analyzeAction(configuration: .debug)
)

let sharedScheme = Scheme.scheme(
    name: "TranslationKeyboardShared",
    shared: true,
    buildAction: .buildAction(targets: ["TranslationKeyboardShared"]),
    testAction: .targets(["TranslationKeyboardSharedTests"], configuration: .debug)
)

// MARK: - Project

let project = Project(
    name: "TranslationKeyboard",
    organizationName: "Amin Benarieb",
    options: .options(
        defaultKnownRegions: ["en", "ru", "es", "fr", "de", "it", "pt", "zh-Hans", "ja", "ko"],
        developmentRegion: "en",
        disableBundleAccessors: false,
        disableSynthesizedResourceAccessors: false
    ),
    settings: .settings(base: baseSettings, release: releaseSettings),
    targets: [
        sharedTarget,
        keyboardTarget,
        appTarget,
        sharedTestsTarget
    ],
    schemes: [
        appScheme,
        sharedScheme
    ]
)
