# Yet Another Translate Keyboard — TODO

## Done
- Source published: github.com/aminbenarieb/translatekb (MIT, public)
- Privacy site live: amin.benarieb.com/translatekb/privacy/
- 18 unit tests pass, Release build clean, CI on Actions
- Public name renamed everywhere: "Yet Another Translate Keyboard"
- All App Store metadata in `Distribution/metadata/` (en, ru, kk, tr)
- 1024 icon (Latin A + Cyrillic Я speech bubbles)
- v0.2.0 voice protocol stub wired

## You — next steps
See `Distribution/SHIP.md`. Summary:
1. Create 2 App IDs + App Group in developer.apple.com (5 min)
2. Create ASC record at appstoreconnect.apple.com (5 min)
3. `tuist generate --open` → Xcode → Archive → Distribute → Upload (10 min)
4. Copy-paste metadata from `Distribution/metadata/` into ASC web UI (15 min)
5. Add yourself as TestFlight tester, smoke test on iPhone
6. Submit for review

## Manual blockers
- `kk` and `tr` description need native-speaker review before public review submission. See `Distribution/metadata/LOCALIZATION_NOTES.md`.

## v0.2.0 queued (separate work)
See `docs/roadmap-v0.2.md`. Five tasks; voice stub done, metadata done. Remaining: anonymous analytics (Task 1), Buy Me a Coffee (Task 2), Settings refactor (Task 3), localized screenshots (Task 4 finish). Not blocking v0.1.0 ship.
