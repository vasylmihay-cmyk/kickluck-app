# KickLuck — First GitHub CI Run

This is the next real milestone. Do not add product features before completing it.

## Step 1 — Create repository

Create a new private GitHub repository, for example:

`kickluck-app`

Do not initialize it with a README if you are uploading this project as the initial repository content.

## Step 2 — Upload Milestone 10

Unzip the package and push the project root.

Typical command sequence:

```bash
git init
git branch -M main
git add .
git commit -m "KickLuck Milestone 10"
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
```

## Step 3 — Add GitHub Actions secret

Repository:
Settings → Secrets and variables → Actions → New repository secret

Add:

`API_FOOTBALL_KEY`

For the very first compile/build validation, signing secrets may be deferred.

For a Google Play upload candidate, later add:

- `KICKLUCK_KEYSTORE_B64`
- `KICKLUCK_STORE_PASSWORD`
- `KICKLUCK_KEY_PASSWORD`
- `KICKLUCK_KEY_ALIAS`

## Step 4 — Run workflow

Open:

Actions → Android AAB → Run workflow

The workflow will:

1. run static preflight;
2. install Java 17;
3. install Flutter stable from Flutter's official GitHub repository;
4. create the Android platform scaffold;
5. patch package ID to `com.kickluck.app`;
6. install Dart/Flutter packages;
7. generate launcher icons;
8. generate native splash;
9. run `flutter analyze`;
10. run `flutter test`;
11. build release Android App Bundle;
12. upload the AAB as the `kickluck-android-aab` artifact.

## Step 5 — What success looks like

All workflow steps are green.

Download:

`kickluck-android-aab`

Inside should be:

`app-release.aab`

That is the first real compiler-validated KickLuck build.

## Step 6 — If the workflow fails

Do not redesign anything.

Open the failed workflow step and copy the exact error output.

The next development cycle is:

**CI error → exact fix → rerun → green build**

This is now more valuable than adding another feature.
