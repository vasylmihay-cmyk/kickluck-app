# KickLuck — Milestone 9 Pre-CI Compile Audit

## Fixed blockers

### 1. MainActivity namespace mismatch
The Android bootstrap changed Gradle namespace/application ID to `com.kickluck.app` but a generated Flutter `MainActivity` would still live in the original generated Java/Kotlin package.

That can build yet fail when Android tries to launch `.MainActivity`.

Milestone 9 patches the MainActivity package declaration and moves the source file to:
`com/kickluck/app/MainActivity`.

### 2. Widget test async persistence initialization
Home uses the cached fixture repository, which initializes `shared_preferences`.

The previous widget test neither initialized mock SharedPreferences nor waited for fixture loading. The test now:
- uses `SharedPreferences.setMockInitialValues({})`;
- waits for mock fixture loading;
- verifies a fixture appears;
- selects it;
- verifies Generate becomes enabled.

### 3. `substring()` index typing
Removed `length.clamp(...)` from substring indexes. This avoids `num`/`int` typing ambiguity across Dart SDK versions.

### 4. League dropdown compatibility
Changed the league dropdown from nullable generic values to an explicit empty-string sentinel for “All leagues”.

### 5. API mapping coverage
Extracted `ApiFootballMapper` and added a real unit test against a representative API-Football fixture payload.

### 6. Local persistence coverage
Added a SavedRepository test using SharedPreferences mock storage.

### 7. Static CI preflight
Added `scripts/preflight.sh` and run it before the Flutter build workflow.

## Still requires a real Flutter CI run
This environment does not contain Flutter/Dart SDK, so Milestone 9 is a static compile audit, not a claim that `flutter analyze`, `flutter test`, or Gradle has already succeeded.

The first GitHub Actions run remains the authoritative compiler/build test.
