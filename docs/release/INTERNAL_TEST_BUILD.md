# KickLuck — Android Internal Test Build

## Decision for v1.0 football data
Use **API-Football behind the existing FixturesRepository abstraction** for the first internal-test build.

This is not a permanent architectural lock-in: provider-specific code remains inside `ApiFootballRepository`.

## 1. Prerequisites
- Current stable Flutter SDK
- Android SDK / Android Studio
- A Google Play Console developer account
- An API-Football key
- An Android upload key before Play Console upload

## 2. API key
Do not commit the football API key.

Example:

```bash
export API_FOOTBALL_KEY="YOUR_KEY"
flutter run --dart-define=API_FOOTBALL_KEY="$API_FOOTBALL_KEY"
```

For release:

```bash
flutter build appbundle --release   --dart-define=API_FOOTBALL_KEY="$API_FOOTBALL_KEY"
```

Important: a secret embedded in a mobile binary is not truly private. Before broader commercial launch, review API-Football's security/usage terms and consider a backend or edge proxy.

## 3. Upload key
Create an upload keystore on the development machine and keep it outside Git.

Example conceptually:

```bash
keytool -genkeypair -v   -keystore ~/kickluck-upload-key.jks   -keyalg RSA -keysize 2048 -validity 10000   -alias upload
```

Copy:

`android/key.properties.example` → `android/key.properties`

Then fill in real values.

Do not commit:
- `.jks`
- `.keystore`
- `key.properties`

## 4. Android application ID
Before the first Play Console release, choose the final unique application ID.

Working suggestion:

`com.kickluck.app`

Changing it after publishing creates a different Play Store application, so freeze it before the first upload.

## 5. Build
Run:

```bash
export API_FOOTBALL_KEY="YOUR_KEY"
./build_internal_test.sh
```

Expected artifact:

`build/app/outputs/bundle/release/app-release.aab`

## 6. Google Play Internal Testing
Create the application in Play Console, then create an Internal Testing release and upload the signed AAB.

Use internal testing first. Do not move directly to production.

## 7. Test checklist
On at least two Android devices / API levels:

- App launches from cold start.
- Today's fixtures load.
- Tomorrow/date navigation works.
- League filter works.
- Team logos fail gracefully.
- 1–5 selection limit works.
- Every generation mode works.
- Random Mix works.
- Lock survives Generate Again.
- All-locked state disables reroll.
- Save persists after app restart.
- History persists after app restart.
- Clear History does not delete Saved Picks.
- Share Image produces a valid PNG.
- Offline Saved/History remain readable.
- API error has Retry.
- Empty match date has Empty state.
- Pull-to-refresh works.

## 8. Release blockers
Do not upload to wider testing until:
- Privacy Policy has a real URL.
- Support email exists.
- Final icon and splash are approved.
- Store screenshots are captured from the real build.
- API provider commercial terms have been reviewed.
