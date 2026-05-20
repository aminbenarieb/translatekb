# Changelog

All notable changes to Yet Another Translate Keyboard. Format roughly follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added — v0.2.0 work in progress
- `VoiceProvider` protocol in `Shared/Sources/Voice/` for v2 voice translation.
  Ships with `AppleSpeechVoiceProvider` stub and `MockVoiceProvider` for tests.
  `TranslationPipeline` gains optional `voiceProvider:` init param and a
  `processVoice(_:from:to:tone:)` convenience that runs transcribe →
  translate → tone in one call. 6 new unit tests; total now 18 passing.
- Localized App Store metadata for `ru-RU`, `kk`, and `tr-TR` —
  subtitle, keywords, description, promotional text, whats_new, URLs.
  Positioning targets the KZ/RU/TR diaspora corridor Apple's iOS 26 Live
  Translation does not cover.
- `Distribution/metadata/LOCALIZATION_NOTES.md` flagging which locales
  need native-speaker review (kk, tr) before submission.
- `docs/roadmap-v0.2.md` — full v0.2.0 enhancement brief covering five
  tasks: analytics, Buy Me a Coffee, Settings CTAs, metadata reposition,
  voice prep.
- `ARCHITECTURE.md` — new "Voice input (v2)" section explaining the
  pipeline integration, memory budget, and permission flow.

## [0.1.0] – 2026-05-19
First TestFlight build.

### Added
- Custom keyboard extension that translates the draft text in place via Apple's on-device Translation framework (iOS 18+).
- Two-protocol architecture: `TranslationProvider` + `ToneAdapter`, composed by `TranslationPipeline`.
- Apple Translation provider (iOS 18+), NoOp tone adapter (v1), and stub Cloud provider + Cloud LLM tone adapter for v2.
- Mock provider + mock adapter for tests; 12 passing unit tests.
- Keyboard layouts: QWERTY (default) and ЙЦУКЕН (Cyrillic), switched by source language.
- Source/target language pickers on the keyboard bar; tone picker in a menu.
- Same-language tone rewriting path — pipeline skips the provider when source == target.
- Main app: Settings, Onboarding, Language Packs (with `prepareTranslation()` pre-download), Keyboard Setup wizard, dev-only Provider Test screen (5 taps on version).
- App Group storage + monthly usage counter.
- Privacy manifests (`PrivacyInfo.xcprivacy`) in both targets — declares no tracking, no data collection.
- 1024 app icon (Latin "A" + Cyrillic "Я" speech bubbles).
- App Store assets: 1320×2868 screenshots, description, keywords, review notes.
- GitHub Actions CI runs the unit test suite on every push.
