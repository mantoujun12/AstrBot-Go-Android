# AstrBot Go (Android)

[English](./README.md) | [简体中文](./README_zh.md)

An unofficial, third-party Android launcher for [AstrBot](https://github.com/AstrBotDevs/AstrBot), the multi-platform LLM chatbot framework. AstrBot runs entirely on your phone, inside a local PRoot-based Debian 13 (arm64) environment — no root required.

This is the Android sibling of [AstrBot-Go](https://github.com/mantoujun12/AstrBot-Go), a Tauri-based desktop launcher.

> **Status: early development.** This repository is not usable yet. No releases, no builds, no guarantees. Unofficial third-party project, not affiliated with the AstrBot team. Use at your own risk. For the official deployment path, see the [AstrBot documentation](https://docs.astrbot.app/).

## Planned architecture

- **Flutter UI** + a **pure Kotlin native runtime layer**. No Jetpack Compose in the final app.
- AstrBot runs locally on the device inside a **PRoot-based Debian 13 (arm64)** environment.
- The bootstrap APK downloads two kinds of artifacts:
  - a **base image** (Debian 13 + Python 3.12 + uv), and
  - per-version **AstrBot packages (wheelhouses)** that install offline into per-instance virtualenvs.
- **Multi-instance launcher**: each instance gets its own data directory, venv, port, logs, and backups.
- Everything is **explicit**: the app never auto-downloads, auto-installs, or auto-upgrades anything. Every action is a button you tap.
- The **WebUI** (chat, plugins, providers) is embedded via WebView; the phone runs instances locally.
- Distribution via **GitHub Releases only** (not on Google Play). **ARM64 devices only.**

## Planned feature scope

| Area | Plan |
| --- | --- |
| UI | Flutter frontend, Kotlin native runtime layer |
| Runtime | PRoot Debian 13 (arm64), Python 3.12 + uv |
| Bootstrap | Base image + per-version AstrBot wheelhouses, installed offline |
| Instances | Multiple instances, each with own data dir, venv, port, logs, backups |
| Versions | Selection UI; CI pre-builds the latest 5 stable AstrBot versions plus on-demand builds; online install is an explicit experimental fallback |
| Network sources | Preset + custom (GitHub proxies, PyPI mirrors) with connectivity tests, mirroring AstrBot-Go's settings |
| Updates | Manual only — nothing automatic, ever |
| WebUI | Embedded via WebView (chat, plugins, providers) |
| Distribution | GitHub Releases, ARM64 only |

## Not in scope

- **Remote start/stop of servers** — the phone runs instances locally; remote management is out of scope.
- Google Play distribution.
- Non-ARM64 devices.

## License

App code is licensed under **MIT**.

Bundled runtime images distribute third-party work: AstrBot (**AGPL-3.0-or-later**), PRoot (**GPL**), and Debian packages. Source offers and license notices ship with each release.
