#!/usr/bin/env bash
# Upload the exported .ipa to TestFlight via App Store Connect API.
#
# Requirements (one-time):
#   1. App Store Connect → Users and Access → Integrations → App Store Connect API
#      → generate a key. Download the .p8 file. Keep the Key ID and Issuer ID.
#   2. Place the .p8 file at one of:
#        ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8
#        ./private_keys/AuthKey_<KEY_ID>.p8
#   3. Export the key/issuer IDs:
#        export ASC_KEY_ID=ABCD123456
#        export ASC_ISSUER_ID=00000000-0000-0000-0000-000000000000
#
# Usage:
#   bash Distribution/scripts/upload-testflight.sh

set -euo pipefail

cd "$(dirname "$0")/../.."

: "${ASC_KEY_ID:?Set ASC_KEY_ID (App Store Connect API Key ID)}"
: "${ASC_ISSUER_ID:?Set ASC_ISSUER_ID (App Store Connect Issuer ID)}"

IPA_PATH=$(find build/export -name '*.ipa' | head -n 1)
if [[ -z "${IPA_PATH:-}" ]]; then
    echo "No .ipa found under build/export. Run export-ipa.sh first." >&2
    exit 1
fi

echo "Uploading $IPA_PATH to TestFlight…"
xcrun altool --upload-app \
    --type ios \
    --file "$IPA_PATH" \
    --apiKey "$ASC_KEY_ID" \
    --apiIssuer "$ASC_ISSUER_ID"

echo
echo "Upload submitted. Check App Store Connect → TestFlight → Builds in a few minutes."
echo "First build processing typically takes 5–20 minutes. Add yourself as an internal tester."
