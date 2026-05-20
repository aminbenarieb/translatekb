# TranslateKB — ship plan

Last updated: 2026-05-19. Update as items complete.

> Full v0.2.0 spec lives in `docs/roadmap-v0.2.md` (also published at
> `amin.benarieb.com/translatekb/roadmap-v0.2/`).

---

## ✅ v0.1.0 — TestFlight prep (done)
- [x] Source code published — github.com/aminbenarieb/translatekb (MIT)
- [x] GitHub Pages live — amin.benarieb.com/translatekb/ + /privacy/
- [x] 1024 app icon (Latin A + Cyrillic Я bubbles)
- [x] Privacy manifests in app + keyboard
- [x] App Store metadata files (description, keywords, URLs, review notes)
- [x] iPhone 6.9" screenshots: Settings, Onboarding
- [x] Fastlane lanes: `create_app`, `sync_metadata`, `sync_screenshots`, `beta`, `release`
- [x] 12 unit tests passing, Release build clean
- [x] CI workflow on GitHub Actions
- [x] Ruby 3.1.2 pin, Gemfile.lock, CHANGELOG

## 👤 v0.1.0 — your remaining work (TestFlight submission)
1. **ASC API key** — generate `.p8`, set `ASC_KEY_ID` / `ASC_ISSUER_ID` / `APPLE_ID` env vars (see `Distribution/SHIP.md`).
2. `bundle exec fastlane create_app`
3. `bundle exec fastlane sync_metadata && bundle exec fastlane sync_screenshots`
4. `bundle exec fastlane beta`
5. Add yourself as internal TestFlight tester, smoke test on iPhone.
6. `bundle exec fastlane release` once happy.

---

## 🚧 v0.2.0 — enhancement brief
See `docs/roadmap-v0.2.md` for full spec.

### 🤖 Auto — I can ship without waiting
- [x] Task 5: Voice translation v2 prep (protocol + stub + pipeline slot + ARCHITECTURE update)
- [x] Task 4 partial: Localized App Store metadata for `ru-RU`, `kk`, `tr-TR`
- [ ] Task 1 foundation: `AnalyticsEvent`, `EventQueue`, `AnalyticsTracker` protocols + queueing tracker + tests (no PostHog key needed yet)
- [ ] Task 2 scaffolding: `TipPresenter`, `TipBannerView`, `TipMilestone` with placeholder URL
- [ ] Task 3 scaffolding: Settings sections, `CrossPromoLoader` with empty config

### 👤 Manual — needs your input
- [ ] **PostHog account** — sign up at posthog.com (free tier), grab project API key, paste into `Config.xcconfig` (gitignored). Without this, analytics records to queue but never flushes.
- [ ] **Buy Me a Coffee URL** — set up `buymeacoffee.com/<handle>` and tell me the URL so I can wire it into `TipPresenter` and Settings.
- [ ] **Cross-promo JSON** — host `cross-promo.json` at `amin.benarieb.com/translatekb/cross-promo.json` (or wherever); empty array is fine until you have other apps to promote.
- [ ] **Localized screenshots** — `kk`, `ru`, `tr` versions of the 5 App Store screenshots. Easiest: run the keyboard on device, take fresh screenshots in each source language. Or build them in Figma.
- [ ] **Native-speaker review** — verify the `kk` and `tr` metadata text I write reads naturally. The Russian copy will be your own check.

### 🎨 Optional polish
- [ ] Replace placeholder icon with a designed one (1024×1024, no alpha)
- [ ] Add 3 more screenshots: source-picker, tone-picker, language-packs (blocked on UI automation or device capture)

---

## 📋 Reference docs in this repo
- `README.md` — public-facing overview
- `ARCHITECTURE.md` — protocol design + Apple Translation bridge rationale
- `docs/roadmap-v0.2.md` — full v0.2.0 enhancement brief
- `Distribution/SHIP.md` — manual TestFlight path via Xcode Organizer
- `Distribution/PrivacyPolicy.md` — source of `docs/privacy/index.md`
- `Distribution/metadata/review_notes.txt` — what Apple App Review reads
