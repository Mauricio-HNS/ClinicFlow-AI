#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${1:-}"
if [[ -z "$API_BASE_URL" ]]; then
  echo "Usage: ./scripts/build_ios_release.sh <https://api.example.com>"
  exit 1
fi

flutter clean
flutter pub get
flutter analyze --no-fatal-infos

flutter build ipa \
  --release \
  --dart-define=APP_API_BASE_URL="$API_BASE_URL"

echo "Done. IPA archive in: build/ios/ipa/"
echo "Note: Apple signing/team setup in Xcode is still required with your account."
