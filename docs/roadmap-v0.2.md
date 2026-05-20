---
layout: default
title: Roadmap v0.2
---

# TranslateKB v0.2.0 — Enhancement Brief

> Status: drafted 2026-05-19. Source of truth for the next version. Each
> task is independent and ships as a separate PR.

## Scope summary

v0.2.0 adds five independent capabilities on top of the v0.1.0 architecture:

1. **Anonymous analytics** — opt-in, privacy-first, queued in extension and flushed by main app.
2. **Buy Me a Coffee monetization** — Sublime Text-style honest tip mechanism, never gating features.
3. **Main app CTAs and discovery** — guideline 4.4.1-compliant Settings redesign + cross-promo slot.
4. **App Store metadata reposition** — KZ/RU/TR diaspora corridor positioning, four localizations.
5. **Voice translation v2 prep** — protocol + stub for Apple Speech-backed `VoiceProvider`.

Existing architecture (protocol-based providers, `TranslationPipeline`,
Apple on-device Translation) is **not refactored** by v0.2.0. New features
slot into the existing seams.

---

## Critical: secrets handling

Never commit any of the following to the public repo:

- API keys (PostHog, Mixpanel, DeepL, OpenAI, Anthropic, Sentry, RevenueCat)
- Provisioning profiles, `.p8`, `.p12`, `.cer`, `.mobileprovision`
- App Store Connect API keys
- Webhook URLs with embedded tokens
- `.env`, `.env.local`, `secrets.xcconfig` with real values

### Build-time secret pattern

Use `.xcconfig` files. Commit `Config.example.xcconfig` with placeholders;
add real `Config.xcconfig` to `.gitignore`. Plumb values through Info.plist
so runtime code reads from `Bundle.main.infoDictionary`.

```
Config.example.xcconfig  ← committed, placeholders
Config.xcconfig          ← gitignored, real keys
```

### Pre-commit grep

```bash
git diff --cached | grep -iE "(api[_-]?key|secret|token|password|bearer)"
```

If anything matches, abort.

### If a secret was ever committed

1. Stop. Do not push.
2. Rotate the secret at the provider immediately.
3. Use `git filter-repo` (not `git rm` — that leaves history).
4. Force-push only after confirming with maintainer.

---

## Task 1 — Anonymous analytics

### Goal
Drive feature decisions with data: which language pairs are used, which host
app contexts the keyboard runs in (only what `UITextDocumentProxy` exposes),
success/failure rates, drop-off points.

### Apple guideline 4.4.1
> "Collect user activity only to enhance the functionality of the user's
> keyboard extension on the iOS device."

Allowed: aggregate counts, language pairs, success rate, host-app *category*
(from `keyboardType` / `textContentType` only).
Forbidden: any text content, anything user-identifying, using keyboard data
for non-keyboard purposes.

### Architecture
Extension writes events to a queue in App Group SQLite — **no network calls
from the extension**. Main app flushes the queue when opened. Users who
never open the main app generate zero telemetry. That's deliberate: it
self-selects for engaged users.

### Events whitelist
```
translate_initiated        { source_lang, target_lang }
translate_succeeded        { source_lang, target_lang, duration_ms_bucketed }
translate_failed           { source_lang, target_lang, error_category }
translate_inserted         { }   // user did NOT delete the translation
language_pair_changed      { from, to }
keyboard_opened            { host_app_category }
first_run_completed        { }
tip_cta_shown / tapped / dismissed   { placement }
```

`host_app_category` ∈ { mail, messaging, web, other } — derived from
`keyboardType` + `textContentType`. Never read host bundle identifier.

### Privacy rules
- Anonymous device ID = random UUID stored once in App Group.
- No IDFA, no IP. PostHog SDK options off.
- All event properties pass through a whitelisting enum. Adding a property = updating the enum (commit diff visible).
- First-run opt-in screen in main app: clear "Yes, share / No thanks" — default opt-OUT until user agrees.
- Settings toggle reversible; toggling OFF purges the queue.

### Files
- `Shared/Sources/Analytics/AnalyticsEvent.swift`
- `Shared/Sources/Analytics/EventQueue.swift` (SQLite in App Group)
- `Shared/Sources/Analytics/AnalyticsTracker.swift` (protocol)
- `Shared/Sources/Analytics/QueuingTracker.swift` (used by keyboard)
- `App/Sources/Analytics/PostHogTracker.swift` (used by main app)
- `App/Sources/Analytics/PostHogFlusher.swift`
- `App/Sources/Settings/PrivacyOnboardingView.swift`

### Key handling
`POSTHOG_API_KEY` in `Config.xcconfig` → Info.plist substitution
`$(POSTHOG_API_KEY)` → loaded by `Bundle.main.infoDictionary["POSTHOG_API_KEY"]`.

---

## Task 2 — Buy Me a Coffee

### Goal
Honest, non-obnoxious tip mechanism. The app stays 100% functional and free.
Tip CTAs appear only after the user has experienced value.

### Constraints
Apple guideline 4.4.1: no marketing, advertising, or IAP **inside the
keyboard extension**. All tip CTAs live in the main app. External link to
buymeacoffee.com is fine (not IAP). The moment a tip "unlocks" anything, it
becomes IAP and Apple will reject.

### Placement
1. **Settings footer** (always visible): "Made in Almaty by Amin. ☕ Buy me a coffee"
2. **Post-onboarding screen** (one-time, after first successful translation): "TranslateKB is free forever. If you'd like to support, ☕"
3. **Milestone banner** at 50/200/500 *inserted* translations.

### Rules
- 30-day cooldown after dismiss.
- After tap: assume positive intent, reset milestone counter.
- Open in Safari via `UIApplication.shared.open(_:)`. **No `SFSafariViewController`** — Apple sometimes flags in-app browsers around payment as IAP-bypass attempts.

### Copy
- ❌ "Tip to unlock", "Premium support", "Help me keep developing"
- ✅ "Buy me a coffee if TranslateKB helped you", "Made by one person in Almaty", "Free forever — tips welcome"

### Tracking
`tip_cta_shown`, `tip_cta_tapped`, `tip_cta_dismissed`. Do **not** track
whether they actually tipped (no way to verify; not your business).

### Files
- `App/Sources/Tip/TipPresenter.swift`
- `App/Sources/Tip/TipBannerView.swift`
- `App/Sources/Tip/TipMilestone.swift`

---

## Task 3 — Main app CTAs and discovery

### Settings sections (top-down)
1. **Keyboard Setup** — instructions, detect actual state if App Group ping is feasible.
2. **Languages** — pair list with on-device availability indicator.
3. **Privacy** — analytics toggle + privacy policy link.
4. **About** — developer name, location (Almaty), GitHub, Buy Me a Coffee.
5. **Other Tools** — placeholder cross-promo module. Render nothing if empty.

### Cross-promo
Reads `https://amin.benarieb.com/translatekb/cross-promo.json`. Schema:

```json
{
  "items": [
    { "appName": "ComboTimer", "tagline": "Combat sports interval timer", "appStoreId": "...", "iconURL": "..." }
  ]
}
```

Renders title + tagline + "View on App Store" button. No marketing copy.

### Onboarding update
After successful first translation:
> "You just saved yourself a context-switch. TranslateKB is free forever and made by one person. If you ever want to support: ☕"

Single dismissable button. Never shown again.

### Files
- `App/Sources/Settings/SettingsView.swift` (refactor existing)
- `App/Sources/CrossPromo/CrossPromoLoader.swift`
- `App/Sources/CrossPromo/CrossPromoView.swift`
- `docs/privacy.md` (already exists — confirm)

---

## Task 4 — App Store metadata reposition

### Why
iOS 26 Live Translation covers English, Chinese, French, German, Italian,
Japanese, Korean, Portuguese, Spanish — but not Russian, Kazakh, Turkish,
Arabic, Ukrainian. The Apple framework lives in iMessage only — not in
WhatsApp, Telegram, Instagram DMs. That gap is the wedge: be the keyboard
for the languages and apps Apple's native solution does not touch.

### Locales
`en-US`, `ru-RU`, `kk`, `tr-TR`. (Kazakh App Store uses Russian primarily,
but `kk` locale signals to Kazakh-speaking diaspora.) `de-DE` optional.

### Title (max ~30 chars)
- en: `TranslateKB — Inline Translate Keyboard`
- ru: `TranslateKB — Клавиатура-переводчик`
- kk: `TranslateKB — Аударма пернетақтасы`
- tr: `TranslateKB — Çeviri Klavyesi`

### Subtitle (max 30 chars)
- en: `Type, tap, translate inline`
- ru: `Перевод в одно касание`
- kk: `Бір түрту арқылы аудару`
- tr: `Tek dokunuşla çevir`

### Keywords (max 100 chars, comma-separated, no spaces, no repetition from title/subtitle)
- en: `translate,keyboard,translator,inline,whatsapp,telegram,bilingual,diaspora,kazakh,russian`
- ru: `переводчик,клавиатура,перевод,whatsapp,telegram,казахский,русский,турецкий,диаспора,билингв`
- kk: `аударма,пернетақта,аудармашы,whatsapp,telegram,қазақ,орыс,түрік`
- tr: `çeviri,klavye,çevirmen,whatsapp,telegram,kazak,rus,diaspora`

### Description structure (target ~1500 chars per locale)
1. **Pain statement** (one sentence, dialect-aware):
   - en: "Stop switching between Google Translate and WhatsApp every time you message your family abroad."
   - ru: "Хватит переключаться между Google Translate и WhatsApp каждый раз, когда пишешь родным."
2. **What it does** (3 short sentences).
3. **What it doesn't do** (counter-position vs predatory competitors):
   - "No subscription. No paywall after 10 uses. No ads. No data collection."
4. **Privacy / on-device**: "Translation happens on your iPhone using Apple's framework. Your messages never leave your device."
5. **Support / contact / GitHub**.

### Screenshots (5 per locale; iPhone 6.9" / 1320×2868 required)
1. **Hook** — fake WhatsApp conversation with translation banner. Source language matches locale.
2. **One-tap action** — hand pointing at Translate key, before/after.
3. **Apps it works in** — WhatsApp, Telegram, Mail, Notes, iMessage logos.
4. **Privacy proof** — "On-device translation. Free. No subscription."
5. **Layouts** — ЙЦУКЕН + QWERTY side by side.

Large captions, readable at thumbnail size.

### App Review Notes (every submission)
> "Free keyboard. No in-app purchases. The 'Buy me a coffee' link in
> Settings opens an external website (buymeacoffee.com) and is a voluntary
> tip mechanism, not a purchase. Full functionality without any payment."

Plus test instructions for keyboard setup (Settings → General → Keyboard →
Add — reviewers regularly miss this).

### Privacy Nutrition Label
- "Data Not Collected" if user opts out.
- "Data Not Linked to You" — Usage Data, Diagnostics (if PostHog enabled, opt-in).

### Files
- `Distribution/metadata/<locale>/title.txt`, `subtitle.txt`, `keywords.txt`, `description.txt`, `whats_new.txt`, `promotional_text.txt`
- Update `fastlane/Deliverfile` if metadata path changes.

---

## Task 5 — Voice translation v2 prep

### Why
Every paid competitor uses Google Speech-to-Text API (~$0.024/min). Apple's
Speech framework is free, on-device on iOS 13+, and mature. None of the
current 12 translate keyboards on App Store do on-device voice. Defensible
wedge for v2.

### Constraints
- Microphone permission must be requested from main app first — prompts in
  extensions are flaky.
- Keyboard extension memory budget ~50MB. Test carefully.
- UI: single mic button, hold-to-record, release-to-translate.

### v1 deliverable (this version)
Stub the protocol so v2 lights up without architectural changes.

```swift
public protocol VoiceProvider: Sendable {
    var identifier: String { get }
    var displayName: String { get }
    func isAvailable() async -> Bool
    func supportedLanguages() async -> [Language]
    func transcribe(audio: AudioBuffer, language: Language) async throws -> String
}

public struct AppleSpeechVoiceProvider: VoiceProvider { /* stub in v1 */ }
```

`TranslationPipeline` gains an optional `voiceProvider: VoiceProvider?`. When
nil, voice features hidden. When present, mic button surfaces in keyboard.

### Files
- `Shared/Sources/Voice/VoiceProvider.swift`
- `Shared/Sources/Voice/AudioBuffer.swift`
- `Shared/Sources/Voice/AppleSpeechVoiceProvider.swift` (stub)
- Update `TranslationPipeline.swift` (additive — optional parameter)
- Update `ARCHITECTURE.md` with v2 roadmap section

---

## Definition of Done — per PR

- [ ] No secrets in committed files (grep check)
- [ ] `.gitignore` updated for new file types
- [ ] New logic has unit tests
- [ ] All existing tests pass
- [ ] `tuist generate` clean checkout
- [ ] `xcodebuild` succeeds for both targets
- [ ] No new warnings
- [ ] README updated if user-facing
- [ ] `CHANGELOG.md` updated

## Final pre-submit checklist

- [ ] Privacy policy URL live
- [ ] App Store Connect metadata for all 4 locales
- [ ] Screenshots for all 4 locales (or en + ru at minimum)
- [ ] App Review Notes filled in
- [ ] Uploaded via Fastlane or Transporter
- [ ] Tested on device with and without Full Access
- [ ] Tested on iOS 17.4 degraded path
- [ ] Tested on iOS 18+ full path

---

## Out of scope for v0.2.0

- Cloud translation providers (DeepL, OpenAI, Anthropic) — v3
- Tone adapters (cloud LLM impl) — v3
- Subscriptions / IAP — explicitly never
- iPad layouts — out of scope per existing README
- Themes / customization — out of scope
- Translation history UI — privacy decision, intentionally not built
- Cross-platform (Android) — separate repo
- Marketing site beyond `docs/` — separate project

---

## Positioning

Honest tool, made by one person, free because the maintainer wants it to be
free, supported by tips from people who find it useful. Every line of code
in v0.2.0 must align with this. If any task drifts toward dark patterns,
gated tips, or non-anonymous tracking — stop and check with the maintainer.
