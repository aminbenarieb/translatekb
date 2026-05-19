# Ship to TestFlight — step-by-step

Everything below is local-file-ready. The remaining work is in Apple's portals
(Developer + App Store Connect) and in Xcode Organizer.

## Prepared in this repo

| File | What it's for |
|------|---------------|
| `App/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png` | 1024×1024 App Store icon (gradient + speech bubble + T). Replace with a designed asset before public launch. |
| `App/Resources/PrivacyInfo.xcprivacy` | Privacy manifest for the container app — declares no tracking, no data collection. |
| `Keyboard/Resources/PrivacyInfo.xcprivacy` | Same manifest for the keyboard extension. |
| `Distribution/PrivacyPolicy.md` | Public privacy policy text. Host this somewhere reachable (GitHub Pages recommended — see below). |
| `Distribution/metadata/en-US/*.txt` | App Store copy — name, subtitle, description, keywords, promotional text, support/marketing/privacy URLs. Copy-paste into App Store Connect. |
| `Distribution/metadata/review_notes.txt` | Notes for App Review (critical for custom keyboards). |
| `Distribution/screenshots/en-US/iPhone-6.9/*.png` | 1320×2868 screenshots — Apple's required size for new iPhone submissions. |
| `Distribution/ExportOptions.plist` | `xcodebuild -exportArchive` options (CLI flow backup). |
| `Distribution/scripts/archive.sh` | Build a Release `.xcarchive`. |
| `Distribution/scripts/export-ipa.sh` | Export a signed `.ipa` from the archive. |
| `Distribution/scripts/upload-testflight.sh` | Upload to TestFlight via the ASC API. |
| `Distribution/scripts/generate-icon.swift` | Regenerate the 1024 icon from CoreGraphics. |

## Step 1 — Apple Developer portal (one-time)

1. Visit https://developer.apple.com/account → Certificates, Identifiers & Profiles.
2. **Identifiers → App IDs → +**:
   - Bundle ID: `com.aminbenarieb.translatekeyboard` (Explicit)
   - Capabilities: enable **App Groups**.
3. **App IDs → +** (second one):
   - Bundle ID: `com.aminbenarieb.translatekeyboard.keyboard` (Explicit)
   - Capabilities: enable **App Groups**.
4. **Identifiers → App Groups → +**:
   - Identifier: `group.com.aminbenarieb.translatekeyboard`
   - Description: "TranslateKB shared container"
5. Edit both App IDs above and link them to that App Group.

Xcode's automatic signing will handle the rest once the App IDs exist.

## Step 2 — App Store Connect (one-time)

1. Visit https://appstoreconnect.apple.com → My Apps → **+** → New App.
2. Fill:
   - Platform: iOS
   - Name: **TranslateKB**
   - Primary language: English (U.S.)
   - Bundle ID: `com.aminbenarieb.translatekeyboard`
   - SKU: `translatekb-ios`
   - User Access: Full
3. App Information:
   - **Subtitle**: paste `Distribution/metadata/en-US/subtitle.txt`
   - **Category**: Primary = *Productivity*, Secondary = *Utilities*
   - **Content Rights**: confirm you have rights / no third-party content
   - **Privacy Policy URL**: paste from `Distribution/metadata/en-US/privacy_url.txt` (host first — see Step 3)
4. Pricing and Availability: Free, all territories.
5. App Privacy → "Data Types": choose **No, we don't collect data from this app**. (We literally don't.)
6. Skip the "Prepare for Submission" page for now — TestFlight first.

## Step 3 — Host the privacy policy

Apple requires a public URL. Cheapest correct option: GitHub Pages.

```bash
# In a *separate* public repo (e.g. translatekb)
mkdir translatekb && cd translatekb
mkdir privacy
cp /path/to/amin_keyboard/Distribution/PrivacyPolicy.md privacy/index.md
echo "# TranslateKB" > index.md
echo "One-tap inline translator. [Privacy policy](privacy/)." >> index.md
git init && git add . && git commit -m "initial"
git branch -M main
# create the public repo on GitHub, then:
git remote add origin git@github.com:aminbenarieb/translatekb.git
git push -u origin main
# GitHub → Settings → Pages → Source: main, root → Save.
```

Public URLs become:
- Marketing/Support: `https://aminbenarieb.github.io/translatekb/`
- Privacy policy: `https://aminbenarieb.github.io/translatekb/privacy/`

These match what's already in `Distribution/metadata/en-US/*_url.txt`. If you choose different URLs, update those files plus App Store Connect.

## Step 4 — Archive in Xcode

```bash
cd /Users/aminbenarieb/repo/indie/amin_keyboard
tuist generate --open
```

In Xcode:

1. Top bar → device selector → **Any iOS Device (arm64)**.
2. Scheme: **TranslationKeyboard** (already shared and Release-configured).
3. Menu → **Product → Archive**. (First time: Xcode will prompt to register
   capabilities — accept.) Archive takes ~1 minute.
4. Xcode Organizer opens automatically → **Archives** tab → newest at the top.

## Step 5 — Upload to TestFlight (Xcode Organizer GUI)

In Organizer:

1. Click your archive → **Distribute App**.
2. **App Store Connect** → Next.
3. **Upload** → Next.
4. Signing: **Automatically manage signing** → Next.
5. Review the summary → **Upload**.
6. Wait ~30 seconds, then "Upload Successful".

Back in App Store Connect:

1. **TestFlight** tab → **Builds** → wait 5–20 minutes for processing.
2. Once processed, fill the build's **Export Compliance** (you'll be asked):
   "Does your app use encryption?" → **No, only standard system encryption**
   (we declared `ITSAppUsesNonExemptEncryption: false` in Info.plist; this
   should auto-resolve, but answer it if prompted).
3. **Internal Testing → Groups → Create Group → "Internal"** → add yourself by
   Apple ID. Builds become available to internal testers immediately, no review.
4. Open the TestFlight iOS app on your iPhone, sign in with the same Apple ID,
   accept the invite, install the build.

## Step 6 — Smoke test the build on device

1. Install via TestFlight.
2. iOS Settings → General → Keyboard → Keyboards → Add New Keyboard → TranslateKB.
3. Tap TranslateKB → **Allow Full Access**.
4. Open Notes → long-press 🌐 → switch to TranslateKB.
5. Type `Привет, как дела?` → tap Translate. Expect "Hi, how are you?" in
   ~1.5 s (longer first time per language pair while Apple downloads packs).
6. In the main app, **Settings → Language packs** → tap Download for any
   languages you want pre-fetched.

## Step 7 — When ready for public review

This is the production submission. TestFlight builds don't need this.

1. App Store Connect → App → **Prepare for Submission**.
2. Paste from `Distribution/metadata/en-US/`:
   - Description ← `description.txt`
   - Keywords ← `keywords.txt`
   - Support URL ← `support_url.txt`
   - Marketing URL ← `marketing_url.txt`
   - Promotional Text ← `promotional_text.txt`
3. Upload screenshots from `Distribution/screenshots/en-US/iPhone-6.9/` (drag
   the 1320×2868 PNGs).
4. App Review Information → paste `Distribution/metadata/review_notes.txt`
   into "Notes". This is **critical** for custom keyboard apps — Apple
   rejects keyboards that don't justify Full Access.
5. Build → select the TestFlight-uploaded build.
6. Version Release: "Manually release this version".
7. Submit for Review.

Custom keyboard apps go through an extra-strict review. Expect 24–72 h. If
rejected, the most common reasons are:
- Insufficient explanation of why Full Access is needed → already addressed in `review_notes.txt`.
- Privacy policy not reachable → confirm the URL loads.
- Functionality not demonstrated → the review notes walk through the exact tap path.

## Step 8 — Iteration cadence

Bump build number (and optionally marketing version) in `Project.swift`,
re-archive, re-upload. Internal testers see the new build immediately;
external testers (if you set them up later) need a fresh review per build
unless changes are minor.

```swift
// Project.swift
let marketingVersion = "0.1.0"  // user-facing
let buildNumber      = "1"      // bump every upload
```

## CLI alternative to Step 5 (optional)

If you'd rather avoid Xcode Organizer and use scripts:

```bash
# 1. Archive
bash Distribution/scripts/archive.sh

# 2. Export signed .ipa
bash Distribution/scripts/export-ipa.sh

# 3a. Drag build/export/*.ipa into Transporter.app, OR

# 3b. Upload via App Store Connect API
#   Generate a key: ASC → Users and Access → Integrations → Keys → +
#   Save .p8 file to ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8
export ASC_KEY_ID="ABCD123456"
export ASC_ISSUER_ID="00000000-0000-0000-0000-000000000000"
bash Distribution/scripts/upload-testflight.sh
```
