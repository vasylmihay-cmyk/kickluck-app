#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.kickluck.app"

echo "KickLuck internal-test build"
echo "Application ID: ${APP_ID}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: Flutter SDK not found."
  exit 1
fi

if [[ -z "${API_FOOTBALL_KEY:-}" ]]; then
  echo "ERROR: API_FOOTBALL_KEY is not set."
  exit 1
fi

flutter doctor -v
flutter pub get

dart run flutter_launcher_icons
dart run flutter_native_splash:create

flutter analyze
flutter test

flutter build appbundle \
  --release \
  --dart-define=API_FOOTBALL_KEY="${API_FOOTBALL_KEY}"

AAB="build/app/outputs/bundle/release/app-release.aab"

if [[ ! -f "${AAB}" ]]; then
  echo "ERROR: expected AAB not found: ${AAB}"
  exit 1
fi

echo
echo "SUCCESS"
echo "AAB: ${AAB}"
echo
echo "Next: upload this bundle to Google Play Console > Testing > Internal testing."
