#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.kickluck.app"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: Flutter SDK not found."
  exit 1
fi

echo "==> Ensuring Android platform scaffold exists"
if [[ ! -f "android/app/build.gradle.kts" && ! -f "android/app/build.gradle" ]]; then
  flutter create --platforms=android .
fi

if [[ -f "android/app/build.gradle.kts" ]]; then
  python3 - <<'PY'
from pathlib import Path
import re
p = Path("android/app/build.gradle.kts")
s = p.read_text()
s = re.sub(r'namespace\s*=\s*"[^"]+"', 'namespace = "com.kickluck.app"', s)
s = re.sub(r'applicationId\s*=\s*"[^"]+"', 'applicationId = "com.kickluck.app"', s)
s = re.sub(r'minSdk\s*=\s*(?:flutter\.minSdkVersion|\d+)', 'minSdk = 23', s)
p.write_text(s)
PY
elif [[ -f "android/app/build.gradle" ]]; then
  python3 - <<'PY'
from pathlib import Path
import re
p = Path("android/app/build.gradle")
s = p.read_text()
s = re.sub(r'namespace\s+["\'][^"\']+["\']', 'namespace "com.kickluck.app"', s)
s = re.sub(r'applicationId\s+["\'][^"\']+["\']', 'applicationId "com.kickluck.app"', s)
s = re.sub(r'minSdkVersion\s+(?:flutter\.minSdkVersion|\d+)', 'minSdkVersion 23', s)
p.write_text(s)
PY
else
  echo "ERROR: Android Gradle app file was not created."
  exit 1
fi

MANIFEST="android/app/src/main/AndroidManifest.xml"
if [[ -f "${MANIFEST}" ]]; then
  python3 - <<'PY'
from pathlib import Path
import re
p = Path("android/app/src/main/AndroidManifest.xml")
s = p.read_text()
if '<uses-permission android:name="android.permission.INTERNET"' not in s:
    idx = s.find(">")
    s = s[:idx+1] + '\n    <uses-permission android:name="android.permission.INTERNET" />' + s[idx+1:]
s = re.sub(r'android:label="[^"]+"', 'android:label="KickLuck"', s)
p.write_text(s)
PY
fi


echo "==> Patching MainActivity package"
MAIN_ACTIVITY="$(find android/app/src/main -type f \( -name 'MainActivity.kt' -o -name 'MainActivity.java' \) | head -n 1 || true)"
if [[ -n "${MAIN_ACTIVITY}" ]]; then
  if [[ "${MAIN_ACTIVITY}" == *.kt ]]; then
    python3 - "${MAIN_ACTIVITY}" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text()
s = re.sub(r'^package\s+[A-Za-z0-9_.]+', 'package com.kickluck.app', s, flags=re.M)
p.write_text(s)
PY
    DEST="android/app/src/main/kotlin/com/kickluck/app/MainActivity.kt"
  else
    python3 - "${MAIN_ACTIVITY}" <<'PY'
from pathlib import Path
import re, sys
p = Path(sys.argv[1])
s = p.read_text()
s = re.sub(r'^package\s+[A-Za-z0-9_.]+;', 'package com.kickluck.app;', s, flags=re.M)
p.write_text(s)
PY
    DEST="android/app/src/main/java/com/kickluck/app/MainActivity.java"
  fi

  mkdir -p "$(dirname "${DEST}")"
  if [[ "${MAIN_ACTIVITY}" != "${DEST}" ]]; then
    mv "${MAIN_ACTIVITY}" "${DEST}"
  fi
fi

echo "==> Android scaffold ready"
echo "Application ID: ${APP_ID}"
