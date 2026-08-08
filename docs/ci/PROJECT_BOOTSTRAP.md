# KickLuck Android Scaffold Bootstrap

Earlier milestones focused on Dart/Flutter product code and did not ship a generated Android platform scaffold.

Milestone 8 closes that gap reproducibly.

Run:

```bash
scripts/bootstrap_android.sh
```

If `android/app` does not exist, it runs:

```bash
flutter create --platforms=android .
```

Then it patches:
- application ID / namespace → `com.kickluck.app`
- min SDK → 23
- app label → `KickLuck`
- Internet permission

This means CI no longer assumes generated Android project files already exist.
