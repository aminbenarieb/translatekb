# Ship checklist

Concise, manual flow. Estimated time: 45 min first time.

## 1. Apple Developer portal (5 min)
developer.apple.com/account → Identifiers
- App ID: `com.aminbenarieb.translatekeyboard` (capability: App Groups)
- App ID: `com.aminbenarieb.translatekeyboard.keyboard` (capability: App Groups)
- App Group: `group.com.aminbenarieb.translatekeyboard`
- Link both App IDs to the App Group.

## 2. App Store Connect record (5 min)
appstoreconnect.apple.com → My Apps → +
- Name: **Yet Another Translate Keyboard**
- Bundle ID: `com.aminbenarieb.translatekeyboard`
- SKU: `yatk-ios`
- Primary language: English (U.S.)

## 3. Archive + upload via Xcode (10 min)
```
tuist generate --open
```
In Xcode: device → **Any iOS Device (arm64)**, Product → Archive.
Organizer → Distribute App → App Store Connect → Upload.
Wait 5–20 min for ASC processing.

## 4. Fill the App Store Connect listing (15 min)
Copy-paste from `Distribution/metadata/` (per locale: en-US, ru-RU, kk, tr-TR):

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
App Privacy: select **No data collected**.

## 5. Screenshots (5 min)
Upload from `Distribution/screenshots/en-US/iPhone-6.9/`:
- `01-settings.png`
- `02-onboarding.png`

Add more later from a TestFlight build on your iPhone.

## 6. TestFlight beta (instant after processing)
- TestFlight → Internal Testing → Create Group "Internal" → add yourself.
- Open TestFlight on iPhone → install → enable keyboard in Settings → smoke test.

## 7. Submit for App Store review
After TestFlight smoke test:
- App Store Connect → Prepare for Submission → select uploaded build → Submit.
- Custom keyboard review: 24–72 h.

---

## What's needed from you

| Item                                | Where you get it                                          |
|-------------------------------------|------------------------------------------------------------|
| Apple ID signed into Xcode          | Already configured for the team `5P8935L6RT`              |
| `kk` and `tr` metadata native review | One Kazakh + one Turkish speaker — see `metadata/LOCALIZATION_NOTES.md` |
