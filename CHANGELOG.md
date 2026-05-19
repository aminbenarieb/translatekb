# Changelog

All notable changes to TranslateKB. Format roughly follows [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

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
- Fastlane lanes for non-interactive ASC operations: `create_app`, `sync_metadata`, `sync_screenshots`, `beta`, `release`.
- GitHub Actions CI runs the unit test suite on every push.
