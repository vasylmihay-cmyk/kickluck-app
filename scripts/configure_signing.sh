#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${KICKLUCK_KEYSTORE_B64:-}" ]]; then
  echo "No signing secret supplied. Continuing without CI release signing patch."
  exit 0
fi

: "${KICKLUCK_STORE_PASSWORD:?Missing KICKLUCK_STORE_PASSWORD}"
: "${KICKLUCK_KEY_PASSWORD:?Missing KICKLUCK_KEY_PASSWORD}"
: "${KICKLUCK_KEY_ALIAS:?Missing KICKLUCK_KEY_ALIAS}"

mkdir -p "$HOME/.kickluck"
KEYSTORE="$HOME/.kickluck/upload-keystore.jks"
printf '%s' "${KICKLUCK_KEYSTORE_B64}" | base64 --decode > "${KEYSTORE}"

cat > android/key.properties <<EOF
storePassword=${KICKLUCK_STORE_PASSWORD}
keyPassword=${KICKLUCK_KEY_PASSWORD}
keyAlias=${KICKLUCK_KEY_ALIAS}
storeFile=${KEYSTORE}
EOF

python3 - <<'PY'
from pathlib import Path
import re

kts = Path("android/app/build.gradle.kts")
groovy = Path("android/app/build.gradle")

if kts.exists():
    s = kts.read_text()
    if 'val keystoreProperties = Properties()' not in s:
        prefix = (
            'import java.util.Properties\n'
            'import java.io.FileInputStream\n\n'
            'val keystoreProperties = Properties()\n'
            'val keystorePropertiesFile = rootProject.file("key.properties")\n'
            'if (keystorePropertiesFile.exists()) {\n'
            '    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n'
            '}\n\n'
        )
        s = prefix + s

    if 'signingConfigs {' not in s:
        anchor = 'android {'
        pos = s.find(anchor)
        if pos == -1:
            raise SystemExit('android block not found')
        pos = s.find('\n', pos) + 1
        block = (
            '    signingConfigs {\n'
            '        create("release") {\n'
            '            keyAlias = keystoreProperties["keyAlias"] as String\n'
            '            keyPassword = keystoreProperties["keyPassword"] as String\n'
            '            storeFile = file(keystoreProperties["storeFile"] as String)\n'
            '            storePassword = keystoreProperties["storePassword"] as String\n'
            '        }\n'
            '    }\n\n'
        )
        s = s[:pos] + block + s[pos:]

    s = re.sub(
        r'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)',
        'signingConfig = signingConfigs.getByName("release")',
        s,
    )
    if 'signingConfig = signingConfigs.getByName("release")' not in s:
        s = re.sub(
            r'(getByName\("release"\)\s*\{)',
            r'\1\n            signingConfig = signingConfigs.getByName("release")',
            s,
            count=1,
        )
    kts.write_text(s)

elif groovy.exists():
    s = groovy.read_text()
    if 'def keystoreProperties = new Properties()' not in s:
        prefix = (
            'def keystoreProperties = new Properties()\n'
            'def keystorePropertiesFile = rootProject.file("key.properties")\n'
            'if (keystorePropertiesFile.exists()) {\n'
            '    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n'
            '}\n\n'
        )
        s = prefix + s

    if 'signingConfigs {' not in s:
        pos = s.find('android {')
        if pos == -1:
            raise SystemExit('android block not found')
        pos += len('android {')
        block = (
            '\n    signingConfigs {\n'
            '        release {\n'
            "            keyAlias keystoreProperties['keyAlias']\n"
            "            keyPassword keystoreProperties['keyPassword']\n"
            "            storeFile file(keystoreProperties['storeFile'])\n"
            "            storePassword keystoreProperties['storePassword']\n"
            '        }\n'
            '    }\n'
        )
        s = s[:pos] + block + s[pos:]

    s = re.sub(r'signingConfig signingConfigs\.debug', 'signingConfig signingConfigs.release', s)
    groovy.write_text(s)
else:
    raise SystemExit('Android Gradle file not found.')
PY

echo "Release signing configured from CI secrets."
