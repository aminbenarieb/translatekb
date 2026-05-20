# Architecture

## Goal

Ship a v1 that translates with Apple's on-device framework, then iterate on
*two independent axes* — translation provider and tone adapter — without
touching keyboard or UI code.

## The two protocols

Everything in the pipeline reduces to two `Sendable` protocols.

### `TranslationProvider`

Translates raw text. Owns its own network, timeout, retry, and language-pack
download policy. Identified by a stable snake_case `identifier` used in logs
and analytics.

```swift
func translate(_ text: String, from: Language?, to: Language)
async throws -> TranslationResult
```

### `ToneAdapter`

Rewrites already-translated text in a specific tone. Must preserve meaning and
output in the same language as input. `NoOpToneAdapter` returns input
unchanged — used for v1 (no AI tone) and as a fail-safe.

```swift
func adapt(_ text: String, tone: Tone, language: Language)
async throws -> String
```

## Composition: `TranslationPipeline`

Takes one provider and one adapter at construction. Every translation goes
through `process(_:)`:

```
TranslationRequest
    ↓
provider.translate(text, from, to)        // → TranslationResult v1
    ↓
(if tone != .neutral)
    ↓
adapter.adapt(translatedText, tone, language) // → String
    ↓
result.withAdaptedText(...)               // → TranslationResult v2
```

The pipeline is the only thing the keyboard and dev tools talk to. Views
never reach for a provider directly.

## Why two protocols, not one

Translation quality is a model choice (Apple, DeepL, OpenAI, …). Tone
adjustment is a model choice that operates on already-correct translations.
They have different cost models, different latencies, and may come from
different vendors. Coupling them into one protocol would force every new
provider to also implement tone (or vice versa), and would prevent A/B-ing
them independently. The split lets us, for example, ship "DeepL translation
+ Claude tone" or "Apple translation + OpenAI tone" without combinatorial
implementations.

## Why the `AppleTranslationProvider` is awkward

Apple's iOS 18 `TranslationSession` is **only** obtainable inside a SwiftUI
view's `.translationTask` modifier. We can't construct one in pure Swift.

To bridge this into the actor world:

1. `AppleTranslationSessionBridge` is an `ObservableObject` holding the
   current `TranslationSession.Configuration` and a continuation for the
   awaiting caller.
2. `AppleTranslationSessionHost` is a hidden `Color.clear` SwiftUI view that
   carries `.translationTask($bridge.configuration) { session in
   bridge.receive(session) }`.
3. The keyboard's hosting controller renders `AppleTranslationSessionHost`
   alongside the keyboard UI so the bridge can always vend a fresh session.
4. `AppleTranslationProvider.translate(...)` calls
   `bridge.session(source:target:)` → updates the binding → SwiftUI's task
   fires → bridge resumes the continuation with the session → provider
   awaits `session.translate(text)`.

This is verbose, but it keeps the protocol clean and means the keyboard view
controller doesn't need to know anything about `TranslationSession`.

iOS 17.4–17.x: `AppleTranslationProvider.isAvailable()` returns `false`. The
main app shows "iOS 18 needed for in-keyboard translation" and could fall
back to the `.translationPresentation` system sheet for ad-hoc translations.

## Shared storage: `AppGroupStorage`

App and extension share preferences via `UserDefaults(suiteName:)` backed by
the App Group. The keyboard reads the user's chosen target language and tone
on `viewWillAppear`; the main app writes them via `UserPreferences`
`@Published` properties.

Keys:

| Key                       | Type         | Owner             |
|--------------------------|--------------|--------------------|
| `defaultSourceLanguage`  | String?      | App (writes)       |
| `defaultTargetLanguage`  | String       | App (writes)       |
| `defaultTone`            | String       | App (writes)       |
| `usageCount`             | Int          | Keyboard (writes)  |
| `usageMonthStart`        | Date         | Keyboard (writes)  |
| `lastUsedProvider`       | String       | Keyboard (writes)  |
| `hasOnboarded`           | Bool         | App (writes)       |

## Concurrency

- `TranslationProvider` and `ToneAdapter` are `Sendable`. Provider work runs
  on whatever actor the caller chooses; the pipeline does not pin to
  `@MainActor`.
- `KeyboardCoordinator` is `@MainActor` so its `@Published` state is safe
  to bind to SwiftUI views.
- `AppleTranslationSessionBridge` is `@MainActor` because SwiftUI's
  `.translationTask` runs there.

## Test seam

`MockTranslationProvider` and `MockToneAdapter` give the pipeline tests
deterministic, side-effect-free seams. They cover:

- neutral tone skips the adapter
- non-neutral tone runs the adapter
- provider errors propagate verbatim
- adapter errors are wrapped in `.adapterFailed`
- empty input throws `.invalidInput` before hitting the provider

The app group storage tests use unique suite names to isolate state between
runs.

## Keyboard memory budget

50MB. Strict rules:

- **Never** import `FoundationModels`. ~1.2GB. Instant OOM-kill.
- Keep `TranslationPipeline` and `AppleTranslationProvider` lazy — created
  on first translate, not at `viewDidLoad`.
- No heavyweight image/audio frameworks.
- Tone adaptation that needs an LLM goes through the network (cloud) in v2,
  not on-device.

## What v2 looks like

Adding a cloud provider:

1. New file `Shared/Sources/Translation/Providers/DeepLProvider.swift`
   implementing `TranslationProvider`.
2. Store API key in `KeychainStorage` with the App Group access group.
3. Add a `provider` setting in `SettingsView` and switch on it in
   `KeyboardCoordinator`'s `pipeline` lazy.

Adding cloud tone:

1. Implement `ToneAdapter` in `CloudLLMToneAdapter.swift` (stub already
   present).
2. Same wiring as above — one swap, no UI changes.

No migrations needed: v1 ships with the same protocols v2 will use.

## Voice input (v2)

v0.2 adds a third optional protocol — `VoiceProvider` — that fits next to
`TranslationProvider` and `ToneAdapter` in the pipeline. `TranslationPipeline`
gains an optional `voiceProvider:` initializer parameter; when nil, the
keyboard hides its mic button.

```swift
public protocol VoiceProvider: Sendable {
    var identifier: String { get }
    var displayName: String { get }
    func isAvailable() async -> Bool
    func supportedLanguages() async -> [Language]
    func transcribe(audio: AudioBuffer, language: Language) async throws -> String
}
```

v1 ships only `AppleSpeechVoiceProvider` (stubbed — `isAvailable()` returns
false) and `MockVoiceProvider` (used by tests). The real Apple Speech-backed
impl is v2 work — `SFSpeechRecognizer` is on-device since iOS 13, no
per-minute cost, and supports the diaspora-corridor languages Apple
Translation already covers.

### Pipeline integration

```swift
let result = try await pipeline.processVoice(
    audioBuffer,
    from: .russian,
    to: .english
)
// internally: voice.transcribe → text → provider.translate → adapter.adapt
```

The voice path **reuses** the rest of the pipeline. Tone adaptation works
identically whether the input came from typing or speech. Same-language
"polish me up" tone rewrites work for transcribed audio too — useful for
"rewrite this dictation in a business tone".

### Memory budget warning

Apple Speech can stay under the 50MB extension limit for short utterances
(<10s) on iOS 18+. Long-form transcription risks an OOM kill. Mic UI must
enforce a max hold duration — probably 15s — and surface "Tap to stop"
before that limit. Real on-device Whisper models would blow the limit; do
not consider them for the extension.

### Microphone permission

Permission prompts from a keyboard extension are flaky — users frequently
deny on first attempt because the prompt context isn't clear. Main app
requests the permission first via `AVAudioSession.requestRecordPermission(_:)`
and shows a contextual explainer. Only after that does the keyboard expose
the mic button.
