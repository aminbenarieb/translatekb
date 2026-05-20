# Ship checklist — fastlane automation

## One-time setup (10 min)

### 1. ASC API key
appstoreconnect.apple.com → Users and Access → Integrations →
App Store Connect API → Keys → **+** → Role: **Admin** → Generate.
Download `AuthKey_<KEY_ID>.p8` (single-shot — Apple won't let you re-download).

```bash
mkdir -p ~/.appstoreconnect/private_keys
mv ~/Downloads/AuthKey_*.p8 ~/.appstoreconnect/private_keys/
```

Copy the **Key ID** and the **Issuer ID** (top of the Keys page). Add to `~/.zshrc`:
```bash
export ASC_KEY_ID=ABCDEF1234
export ASC_ISSUER_ID=00000000-0000-0000-0000-000000000000
export APPLE_ID=amin.benarieb@gmail.com
```
`source ~/.zshrc`

### 2. Install fastlane
```bash
bundle install
```

## Each release

```bash
bundle exec fastlane create_app        # one-time: ASC record + App IDs + App Group
bundle exec fastlane sync_metadata     # description / keywords / URLs (4 locales)
bundle exec fastlane sync_screenshots  # PNGs from Distribution/screenshots/
bundle exec fastlane beta              # archive + upload to TestFlight
# install on iPhone via TestFlight app, smoke test
bundle exec fastlane release           # submit current build for App Store review
```

## What lives where

- Metadata: `Distribution/metadata/{en-US,ru-RU,kk,tr-TR}/*.txt`
- Screenshots: `Distribution/screenshots/en-US/iPhone-6.9/`
- Review notes: `Distribution/metadata/review_notes.txt`
- Lanes: `fastlane/Fastfile`
- Deliverfile: `fastlane/Deliverfile` (points at the metadata path)

## Review

Custom keyboard apps: 24–72 h. Apple's review notes already cover
Full Access justification, no-keystroke-logging assertion, and a
step-by-step demo path for both English and Russian source.
