#!/usr/bin/env bash
# Produce a Release archive for App Store distribution. Run from repo root.
#
# Usage:
#   bash Distribution/scripts/archive.sh
#
# Output: build/TranslateKB.xcarchive

set -euo pipefail

cd "$(dirname "$0")/../.."

ARCHIVE_PATH="build/TranslateKB.xcarchive"

# Ensure the project is up to date with Project.swift
tuist generate --no-open

# Clean previous archive
rm -rf "$ARCHIVE_PATH"
mkdir -p build

xcodebuild \
    -workspace TranslationKeyboard.xcworkspace \
    -scheme TranslationKeyboard \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates \
    clean archive

echo
echo "Archive ready at $ARCHIVE_PATH"
echo "Next: open Xcode → Window → Organizer → Archives, or run export-ipa.sh"
