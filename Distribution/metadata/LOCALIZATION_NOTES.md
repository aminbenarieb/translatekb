# Localization notes

This metadata package covers four App Store locales:

| Locale  | Status                              |
|---------|-------------------------------------|
| en-US   | Native — authoritative              |
| ru-RU   | Native — author reviewed            |
| kk      | Machine + structural — needs native-speaker review for natural phrasing |
| tr-TR   | Machine + structural — needs native-speaker review for natural phrasing |

## What to double-check before submitting

### Russian (ru-RU)
- Verify the informal "ты" tone matches the brand voice. If you'd rather sound more neutral/polite, switch to "вы" forms in `description.txt`, `subtitle.txt`, and `whats_new.txt`.
- Keyword field is exactly within the 100-char limit.

### Kazakh (kk)
- The `kk` text uses common Kazakh forms but a native speaker should sanity-check phrasing in `description.txt`. Particular candidates for refinement:
  - "Қара жоба" (draft) — could also be "жоба" alone.
  - "Толық қол жетімділікке рұқсат беруді" — verb form matches the iOS UI string but may sound clunky.
- App Store will display the listing in Kazakh-region devices. For Russian-speaking Kazakhstan users, the `ru-RU` listing applies — both are useful.

### Turkish (tr-TR)
- "Cihaz üstü çeviri" is the standard rendering of "on-device translation". A native Turkish iOS user would say it this way; verify against Apple's own Turkish localization for Translation.app.
- Keyboard names in body text use the brand spelling "Yet Another Translate Keyboard" — don't translate the product name itself.

## Adding more locales

Mirror the `en-US/` structure. Required files for fastlane `deliver`:

```
<locale>/
  name.txt              # max 30 chars
  subtitle.txt          # max 30 chars
  description.txt       # max ~4000 chars, aim for ~1500
  keywords.txt          # max 100 chars, comma-separated, no spaces
  promotional_text.txt  # max 170 chars
  support_url.txt
  marketing_url.txt
  privacy_url.txt
  whats_new.txt         # per-version release note
```

Run `bundle exec fastlane sync_metadata` to upload to App Store Connect.
