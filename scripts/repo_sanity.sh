#!/usr/bin/env bash
set -euo pipefail

echo "KickLuck repository sanity check"

required=(
  "pubspec.yaml"
  "lib/main.dart"
  "lib/app/kickluck_app.dart"
  "lib/features/generator/domain/random_engine.dart"
  ".github/workflows/android-aab.yml"
  "scripts/bootstrap_android.sh"
  "scripts/configure_signing.sh"
  "scripts/preflight.sh"
)

for file in "${required[@]}"; do
  if [[ ! -f "${file}" ]]; then
    echo "MISSING: ${file}"
    exit 1
  fi
done


echo "Repository sanity check passed."
