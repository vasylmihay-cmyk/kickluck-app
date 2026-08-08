# KickLuck — Android Production Configuration

## Frozen working identifiers

### Application ID
`com.kickluck.app`

Use this before the first Google Play upload. Once a package/application ID is published, changing it creates a separate application identity.

### App name
`KickLuck`

### Version
Current milestone:
- versionName: `0.7.0`
- versionCode: `7`

Before every new Play Console bundle upload, increment the build number/versionCode.

## Android SDK targets

Use the current Flutter-generated Android project defaults where possible.

Before upload, verify the project targets the Google Play minimum currently required for new apps. As of the current project preparation date, Google Play requires new apps and updates to target Android 15 / API 35 or higher.

## AndroidManifest requirements

KickLuck requires internet access for football fixtures and remote team logos.

The final Android manifest must include:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

KickLuck v1.0 should not request:
- precise location
- contacts
- microphone
- camera
- SMS
- phone state

No permission should be added unless a released feature genuinely requires it.

## Release application label

Inside the application entry:

```xml
android:label="KickLuck"
```

## Network

API-Football traffic uses HTTPS. Do not enable cleartext traffic globally.

## Signing

Release AAB must be signed with the developer upload key before Play Console upload.

Never commit:
- `android/key.properties`
- `*.jks`
- `*.keystore`

## Play App Signing

Use Play App Signing for distribution. The developer controls the upload key; Google Play manages the app-signing key used for distributed APKs.

## Build

```bash
export API_FOOTBALL_KEY="YOUR_KEY"

flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter test

flutter build appbundle   --release   --dart-define=API_FOOTBALL_KEY="$API_FOOTBALL_KEY"
```

Expected artifact:

`build/app/outputs/bundle/release/app-release.aab`
