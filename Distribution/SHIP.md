# Ship checklist

Manual flow, ~30 min first time.

## 1. App Store Connect record (5 min)
appstoreconnect.apple.com → My Apps → +
- Name: **Yet Another Translate Keyboard**
- Bundle ID: `com.aminbenarieb.translatekeyboard`
- SKU: `yatk-ios`
- Primary language: English (U.S.)

## 2. Open the project (1 min)
```
tuist generate --open
```

In Xcode: top-bar device selector → **Any iOS Device (arm64)**.
Both targets already have "Automatically manage signing" on with team
`5P8935L6RT` — Xcode creates the two App IDs and the App Group on the
developer portal automatically during the first archive.

## 3. Archive + upload (10 min)
Menu → Product → **Archive**. Wait ~2 min.
Organizer auto-opens → Distribute App → App Store Connect → Upload.
Processing in ASC: 5–20 min.

## 4. Fill the ASC listing (15 min)
Copy-paste from `Distribution/metadata/` per locale (`en-US`, `ru-RU`, `kk`, `tr-TR`):

| ASC field            | File                              |
|----------------------|-----------------------------------|
| Name                 | `<locale>/name.txt`               |
| Subtitle             | `<locale>/subtitle.txt`           |
| Promotional Text     | `<locale>/promotional_text.txt`   |
| Description          | `<locale>/description.txt`        |
| Keywords             | `<locale>/keywords.txt`           |
| What's New           | `<locale>/whats_new.txt`          |
| Support URL          | `<locale>/support_url.txt`        |
| Marketing URL        | `<locale>/marketing_url.txt`      |
| Privacy Policy URL   | `<locale>/privacy_url.txt`        |
| Copyright            | `metadata/copyright.txt`          |
| App Review Notes     | `metadata/review_notes.txt`       |

Categories: Primary **Productivity**, Secondary **Utilities**.
App Privacy: **No data collected**.
Screenshots: drag from `Distribution/screenshots/en-US/iPhone-6.9/`.

## 5. TestFlight (instant)
TestFlight → Internal Testing → Create Group "Internal" → add yourself by Apple ID.
TestFlight app on iPhone → install → enable keyboard in Settings → smoke test.

## 6. Submit for review (after smoke test)
Prepare for Submission → pick uploaded build → Submit. Custom keyboard review: 24–72 h.

---

**You do not need an ASC API key.** That's only for non-interactive
automation (fastlane, scripts). You're going through the web UI manually.
Skip it.

**You do not need to create App IDs manually** in developer.apple.com.
Xcode creates them when you Archive with automatic signing. Only step in
the developer portal might be approving the App Group capability — Xcode
prompts if needed.
