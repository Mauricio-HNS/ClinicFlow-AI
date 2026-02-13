#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${1:-}"
if [[ -z "$API_BASE_URL" ]]; then
  echo "Usage: ./scripts/build_android_release.sh <https://api.example.com>"
  exit 1
fi

if [[ ! -f "android/key.properties" ]]; then
  echo "Missing android/key.properties."
  echo "Create it from android/key.properties.example before building release."
  exit 1
fi

flutter clean
flutter pub get
flutter analyze --no-fatal-infos

flutter build appbundle \
  --release \
  --dart-define=APP_API_BASE_URL="$API_BASE_URL"

echo "Done. AAB at: build/app/outputs/bundle/release/app-release.aab"
