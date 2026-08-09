# KickLuck MVP — v0.9.1

GitHub-ready CI release candidate.

## What is complete
- Product concept and UX/UI
- Flutter application structure
- Random Engine
- Lock / Regenerate
- Saved Picks
- History
- Settings
- Theme and language preferences
- Responsible-use, privacy and terms screens
- Clear History and Saved Picks controls
- Share image
- Real fixtures repository adapter
- Fixture cache
- Release-prep assets
- Android scaffold bootstrap
- GitHub Actions AAB workflow
- Pre-CI static audit
- Repository sanity checks

## What is intentionally NOT claimed
This environment does not have Flutter/Dart installed, so no local Flutter compilation or AAB build has been performed here.

## Next authoritative step
Push this repository to GitHub and run:

**Actions → Android AAB → Run workflow**

Required secret for the first real-data build:

`API_FOOTBALL_KEY`

Read:

`docs/ci/FIRST_GITHUB_RUN.md`

The next engineering decision should be based on the exact CI compiler/build output.
