# AGENTS.md

## Collaboration

- Stay professional and upbeat; use emojis sparingly.
- Lead with the conclusion, then the key evidence and follow-up actions. Avoid making readers re-derive the process.
- Read the relevant code, docs, and configuration before making changes, and follow the existing structure. Do not rewrite unrelated modules for a narrowly scoped request.
- The workspace may already contain changes from the user or other collaborators. Preserve them and build on top of them. Never revert, overwrite, or delete them without authorization.
- If an ambiguity would materially affect the result, state the assumption or ask the user first. When a safe validation is possible within the current scope, prefer performing it yourself.
- Apply the same care to Git operations. Commit, push, create or modify a PR, or rewrite history only after the user explicitly requests it. For irreversible operations, explain the impact and obtain confirmation first.

## Project Overview

`AstrBot-Go-Android` is an unofficial, third-party Android launcher for [AstrBot](https://github.com/AstrBotDevs/AstrBot). It runs AstrBot locally on the device inside a PRoot-based Debian 13 (arm64) environment, manages multiple instances, and embeds the AstrBot WebUI. It is the Android sibling of [AstrBot-Go](https://github.com/mantoujun12/AstrBot-Go) (Tauri desktop launcher).

Reference links:

- [AstrBot upstream repository](https://github.com/AstrBotDevs/AstrBot)
- [AstrBot-Go desktop launcher](https://github.com/mantoujun12/AstrBot-Go)
- Proven PRoot-on-Android reference: [astrbot-for-android](https://github.com/JunWan666/astrbot-for-android) (MIT; architecture reference only)

Repository documentation layout:

- `docs/ARCHITECTURE.md`: **source of truth** for v1 scope, runtime layering, install policy, CI, and security. Read it before changing anything the runtime depends on; update it in the same change when a locked decision changes.
- `docs/P0_VERIFICATION.md`: the go/no-go checklist for the PRoot runtime. Any change to the PRoot invocation, bind mounts, or base image must be validated against it.
- `README.md` (English) and `README_zh.md` (Simplified Chinese): keep both synchronized when features, platform support, tech stack, commands, links, or licensing details change.
- `runtime/`: base image build scaffolding. Not shipped in the APK.

## Tech Stack

- UI: Flutter (Dart), living in `lib/`.
- Native layer: pure Kotlin (foreground service, PRoot process management, downloads, Keystore). **No Jetpack Compose in the final app.**
- Runtime: PRoot + Debian 13 arm64 base image, Python 3.12 (uv-managed), per-instance venvs.
- Build: Flutter toolchain for the app; Gradle (wrapper under `android/`) for advanced Android-module work.
- CI: GitHub Actions; runtime artifacts build on ARM64 runners (`ubuntu-24.04-arm`).

## Current State vs Target

The repository currently holds a Flutter app shell (an early-development home screen only) plus project docs, CI, and runtime scaffolding. The real launcher UI (instances, versions, logs, settings), the native runtime service, and the PRoot integration are unbuilt and arrive with the P1 milestone per `docs/ARCHITECTURE.md`. Flutter code lives in `lib/` (feature-first structure); Android-specific code lives in `android/app/src/main/kotlin/...`.

## Development Commands

```
flutter pub get              # Fetch Dart packages
flutter analyze              # Static analysis
flutter test                 # Run Flutter unit/widget tests
flutter build apk --debug    # Build the debug APK
```

Gradle is only needed for advanced Android-module work, and it runs from the `android/` directory (e.g. `cd android && ./gradlew :app:assembleDebug`). Do not hand-edit `android/gradle/wrapper/*`.

Runtime base image (requires Docker + buildx; qemu on x86_64 hosts):

```
bash runtime/scripts/export-rootfs.sh dist      # build + export rootfs.tar.zst + manifest
```

### China network notes

Local builds on mainland-China networks should export:

- `FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn`
- `PUB_HOSTED_URL=https://pub.flutter-io.cn`

Without the first one, Flutter engine artifacts download from
`storage.googleapis.com/download.flutter.io` at dial-up speeds. The Android
module already prefers Aliyun Maven mirrors (`android/settings.gradle.kts`,
`android/build.gradle.kts`), and the Gradle wrapper distribution is pinned;
do not commit machine-specific mirror overrides beyond these locations.

## Native Layer Conventions

- Implement filesystem, process, download, archive, and Keystore operations in Kotlin. Expose them to Flutter through MethodChannel/EventChannel contracts with stable, JSON-serializable parameter and return types. Pages and widgets depend only on clear business methods, not on channel internals.
- Pass external process arguments as arrays. Never concatenate user input into a shell command. Handle the working directory, environment, and exit codes explicitly.
- The foreground service owns all guest processes; Activities and WebViews never own them. Supervise process groups; a stopped instance must leave no orphan PRoot or Python children.
- Downloads go to a staging directory, verify SHA-256 (and signature for catalog artifacts) before an atomic rename, and never overwrite an installed artifact in place.
- Instance ids, ports, and names are validated at the boundary; bind-mount sources must stay inside the app's private storage.
- Never log secrets, tokens, full user paths, or raw process arguments with embedded secrets.

## Install Policy (hard product rule)

The app never auto-downloads, auto-installs, auto-repairs, or auto-upgrades anything. Every install, repair, download, and version switch is a user-initiated action with confirmed sizes and observable progress. The only automatic behaviors are user-enabled crash auto-restart and boot restore. A change that violates this policy is wrong regardless of how convenient it is.

## Data and Security

- Deletion, overwrite, restore, rollback, and process termination are high-risk operations. The UI must require explicit confirmation, and the native layer must validate the target again.
- Base images are immutable per `baseId`; instances pin their `baseId`. Never mutate an extracted rootfs in place — ship a new `baseId` instead.
- Backup and restore must retain version, timestamp, and a manifest, and prefer temporary files plus atomic renames for critical writes.
- WebUI defaults to `DASHBOARD_HOST=127.0.0.1`; the LAN toggle is per instance, explicit, and warning-bearing.
- Secrets (per-instance WebUI initial password, desktop-session secret) live in the Android Keystore, never in plain preferences or logs.
- `allowBackup` stays `false`; runtime images and instance data must never enter Android cloud backup.

## Copy and Internationalization

- Chinese copy uses full-width punctuation `，。：；？！（）“”`; English copy, code, and locale files use ASCII punctuation.
- Keep `README.md` and `README_zh.md` synchronized when content changes; do not update one language only.
- Only adjust punctuation in comments and string literals, never inside URLs, regexes, version numbers, or format placeholders.

## Verification Requirements

- For app changes, run at least `flutter analyze` and `flutter test`; for Android module or manifest changes, also run `flutter build apk --debug`.
- For changes touching the PRoot invocation, bind mounts, base image, or wheelhouse layout, document the manual device verification against `docs/P0_VERIFICATION.md`; CI alone is insufficient.
- Add unit tests for new critical pure logic, prioritizing path/port validation, manifest verification, version comparison, and state machines.
- Report only the commands actually run and their results. Clearly disclose checks that were not run and any remaining risks.

## Changelog and Release

- Follow [Semantic Versioning](https://semver.org/); user-facing changes go to `changelogs/unreleased.md` in the same change under `Added` / `Changed` / `Fixed` / `Security` as applicable. Internal refactors, CI, and docs-only changes may skip it.
- Keep changelog files bilingual with `## English` first and `## 中文` second, omitting empty sections.
- Releases publish to GitHub Releases only (never Google Play) and must carry: the signed APK, the signed catalog, base image and version packages with SHA-256 manifests, and third-party NOTICE/source materials (AstrBot is AGPL-3.0-or-later, PRoot is GPL-2.0-or-later, Debian packages keep their own licenses).

## Commit Conventions

Use Conventional Commits with English messages, one responsibility per commit.

Allowed types:

- `feat:` New feature
- `fix:` Bug fix
- `refactor:` Refactoring that does not change external behavior
- `chore:` Build, dependency, configuration, or maintenance work
- `docs:` Documentation-only changes
- `ci:` CI workflow changes

Use branch names based on the change type: `feat/xxx`, `fix/xxx`, `refactor/xxx`, `chore/xxx`, `docs/xxx`, `ci/xxx`.

## Pull Requests

- Start the title with a Conventional Commit type.
- Explain the purpose, main changes, user-visible impact, and verification actually performed.
- For runtime, download, backup, or process operations, document risks and rollback steps.
- Do not conceal incomplete work, untested platforms, or known issues. Keep the PR scoped and independently reviewable.
