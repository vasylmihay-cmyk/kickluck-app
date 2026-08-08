#!/usr/bin/env bash
set -euo pipefail

echo "KickLuck preflight"

test -f pubspec.yaml
test -f lib/main.dart
test -f lib/features/generator/domain/random_engine.dart
test -f .github/workflows/android-aab.yml
test -f scripts/bootstrap_android.sh


echo "Static preflight passed."
