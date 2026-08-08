# KickLuck — GitHub Actions AAB Build

Milestone 8 adds a reproducible cloud build for the Android App Bundle.

## What the workflow does
- checks out the repository;
- installs Java;
- clones Flutter stable from Flutter's official GitHub repository;
- generates the missing Android platform scaffold;
- patches application ID to `com.kickluck.app`;
- optionally configures upload-key signing from encrypted GitHub Secrets;
- runs `flutter analyze`;
- runs tests;
- builds the release AAB;
- uploads the AAB as a GitHub Actions artifact.

Flutter's official Android deployment guide uses `flutter build appbundle` for Google Play Android App Bundles.

## Required repository secret
`API_FOOTBALL_KEY`

GitHub:
Settings → Secrets and variables → Actions → New repository secret.

GitHub repository secrets are encrypted and only become available to workflow steps when referenced explicitly.

## Signing secrets for Play upload
Add:
- `KICKLUCK_KEYSTORE_B64`
- `KICKLUCK_STORE_PASSWORD`
- `KICKLUCK_KEY_PASSWORD`
- `KICKLUCK_KEY_ALIAS`

Create the Base64 keystore value on a trusted machine.

Linux:
```bash
base64 -w 0 ~/kickluck-upload-key.jks
```

macOS:
```bash
base64 < ~/kickluck-upload-key.jks | tr -d '\n'
```

Do not commit the keystore or Base64 text.

## Build
Repository → Actions → Android AAB → Run workflow.

After success, download artifact:
`kickluck-android-aab`

GitHub Actions workflow artifacts are designed for build outputs and can be downloaded from the completed workflow run.

## Important
Without the signing secrets, CI can still validate source, tests and build setup, but configure the upload key before treating the bundle as the Google Play upload candidate.
