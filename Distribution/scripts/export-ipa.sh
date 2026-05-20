#!/usr/bin/env bash
# Export a signed .ipa from the archive for App Store upload. Run after archive.sh.
#
# Usage:
#   bash Distribution/scripts/export-ipa.sh
#
# Output: build/export/TranslationKeyboard.ipa

set -euo pipefail

cd "$(dirname "$0")/../.."

ARCHIVE_PATH="build/TranslateKB.xcarchive"
EXPORT_PATH="build/export"
OPTIONS_PLIST="Distribution/ExportOptions.plist"

if [[ ! -d "$ARCHIVE_PATH" ]]; then
    echo "Archive not found at $ARCHIVE_PATH. Run archive.sh first." >&2
    exit 1
fi

rm -rf "$EXPORT_PATH"
mkdir -p "$EXPORT_PATH"

xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$OPTIONS_PLIST" \
    -exportPath "$EXPORT_PATH" \
    -allowProvisioningUpdates

echo
echo "IPA ready in $EXPORT_PATH"
echo "Next: drag the .ipa into Transporter.app, or run upload-testflight.sh"
