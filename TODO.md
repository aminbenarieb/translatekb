# TranslateKB — ship plan

Last updated: 2026-05-19. Update as items complete.

## ✅ Done
- [x] Source code published — github.com/aminbenarieb/translatekb (MIT)
- [x] GitHub Pages live — amin.benarieb.com/translatekb/ and /privacy/
- [x] 1024 app icon (Latin A + Cyrillic Я bubbles)
- [x] Privacy manifests in app + keyboard targets
- [x] App Store metadata files (description, keywords, URLs, review notes)
- [x] iPhone 6.9" screenshots (1320×2868): Settings, Onboarding
- [x] Fastlane lanes wired: `create_app`, `sync_metadata`, `sync_screenshots`, `beta`, `release`
- [x] 12 unit tests passing, Release build passes

## 🤖 Auto — I can do now
- [ ] Pin Ruby to 3.1.2 (`.ruby-version` file)
- [ ] `bundle install` to verify Gemfile resolves
- [ ] `bundle exec fastlane lanes` — validate Fastfile syntax
- [ ] Add CI workflow (`.github/workflows/test.yml`) — runs unit tests on PR/push
- [ ] Add 3 more App Store screenshots: source-picker, tone-picker, language-packs
- [ ] Commit + push all of the above

## 👤 Manual — you must do
Auth + verification steps that need your Apple ID interactively:

1. **One-time App Store Connect API key** (10 min)
   - appstoreconnect.apple.com → Users and Access → Integrations → App Store Connect API → Keys → "+" → Admin role
   - Download `AuthKey_<ID>.p8` (single download — Apple doesn't let you re-download)
   - `mkdir -p ~/.appstoreconnect/private_keys && mv ~/Downloads/AuthKey_*.p8 ~/.appstoreconnect/private_keys/`
   - Add to `~/.zshrc`:
     ```bash
     export ASC_KEY_ID=ABCDEF1234
     export ASC_ISSUER_ID=00000000-0000-0000-0000-000000000000
     export APPLE_ID=amin.benarieb@gmail.com
     ```
   - `source ~/.zshrc`

2. **Create app records** (fastlane handles the click-through):
   ```bash
   bundle exec fastlane create_app
   ```
   This creates both App IDs (`...translatekeyboard`, `...translatekeyboard.keyboard`), the App Group, and the App Store Connect record.

3. **Push metadata + screenshots to ASC**:
   ```bash
   bundle exec fastlane sync_metadata
   bundle exec fastlane sync_screenshots
   ```

4. **First TestFlight upload**:
   ```bash
   bundle exec fastlane beta
   ```
   ~3–5 min build + ~5–20 min ASC processing.

5. **Internal tester + smoke test**:
   - ASC → TestFlight → Internal Testing → Create Group "Internal" → add yourself
   - Open TestFlight on iPhone, install build, enable keyboard, test translate
   - Bug fixes? bump build number in `Project.swift`, re-run `bundle exec fastlane beta`

6. **App Store submission for review** (after you're happy with TestFlight):
   ```bash
   bundle exec fastlane release
   ```
   Apple review: 24–72 h for custom keyboards.

## 🎨 Optional polish (manual)
- [ ] Replace placeholder icon with a designed one (1024×1024 PNG, no alpha)
- [ ] Add more screenshots (App Store allows 10 per device size; 3–5 is the sweet spot)
- [ ] Localize App Store listing to Russian (mirror `Distribution/metadata/en-US/` → `metadata/ru/`)
- [ ] Custom landing page design at `docs/index.md` (currently minimal)

## 📋 Reference docs in this repo
- `README.md` — public-facing overview
- `ARCHITECTURE.md` — protocol design + Apple Translation bridge rationale
- `Distribution/SHIP.md` — Xcode Organizer fallback path (if fastlane breaks)
- `Distribution/PrivacyPolicy.md` — source of `docs/privacy/index.md`
- `Distribution/metadata/review_notes.txt` — what Apple App Review reads
