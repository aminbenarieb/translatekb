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
1. Generate ASC API key (Admin role), set `ASC_KEY_ID` / `ASC_ISSUER_ID` / `APPLE_ID` env vars
2. `bundle install`
3. `bundle exec fastlane create_app` (creates ASC record + App IDs + App Group)
4. `bundle exec fastlane sync_metadata && bundle exec fastlane sync_screenshots`
5. `bundle exec fastlane beta` → install on iPhone via TestFlight → smoke test
6. `bundle exec fastlane release` to submit for App Store review

## Manual blockers
- `kk` and `tr` description need native-speaker review before public review submission. See `Distribution/metadata/LOCALIZATION_NOTES.md`.

## v0.2.0 queued (separate work)
See `docs/roadmap-v0.2.md`. Five tasks; voice stub done, metadata done. Remaining: anonymous analytics (Task 1), Buy Me a Coffee (Task 2), Settings refactor (Task 3), localized screenshots (Task 4 finish). Not blocking v0.1.0 ship.
