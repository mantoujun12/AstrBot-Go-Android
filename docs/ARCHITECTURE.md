# AstrBot Go (Android) — v1 Architecture

This document is the **source of truth** for v1 scope and design. It records decisions already made; other docs link here rather than restating them. Anything not in this document is out of scope for v1 (see the final section).

## Locked decisions

| # | Area | Decision |
|---|------|----------|
| 1 | Positioning | Local multi-instance **AstrBot launcher / management panel** — not a chat client. Chat, plugins, and provider configuration stay in the embedded AstrBot WebUI. |
| 2 | UI | **Flutter**. Native layer is **pure Kotlin** (services, PRoot process management, downloads, Keystore). No Jetpack Compose in the final app; the currently committed Compose template will be replaced wholesale. |
| 3 | Runtime | Single **base image**: Debian 13 arm64 + Python 3.12 + uv, running under **PRoot**. No root, no Docker, no Termux dependency. |
| 4 | Instances | Per-instance venv, data dir, logs, backups, and WebUI port. Shared: read-only base image and a shared uv cache (`UV_LINK_MODE=hardlink`). |
| 5 | Versions | Free version selection via a version-catalog UI. CI pre-builds the **latest 5 stable** AstrBot wheelhouses; a manual `workflow_dispatch` build covers arbitrary versions; an explicit **experimental online-install fallback** exists for versions without a prebuilt package. Versions that require Python 3.10 only are marked **incompatible in v1**. |
| 6 | Install policy | **Everything explicit.** The app never auto-downloads, auto-installs, auto-repairs, or auto-upgrades. The only automatic behaviors are user-enabled **crash auto-restart** and **boot restore**. |
| 7 | Distribution | Bootstrap APK + downloadable runtime artifacts on **GitHub Releases only** (not Google Play). ARM64 devices only. `minSdk 28`, `targetSdk 37`, with a documented fallback to 35 if P0 verification fails. |
| 8 | Deferred features | LAN QR codes, notification action buttons, instance import/export, scheduled backups, remote instances — all explicitly **deferred out of v1**. |

## Three-layer runtime

```
+---------------------------------------------------------------+
| Bootstrap APK                                                  |
|   Flutter UI + Kotlin service layer + bundled PRoot binaries    |
+---------------------------------------------------------------+
        |  downloads once, verified (SHA-256 + signature)
        v
+---------------------------------------------------------------+
| Base image  base-<id>-arm64.tar.zst                            |
|   Debian 13 arm64 / Python 3.12 / uv  -- shared, read-only     |
+---------------------------------------------------------------+
        |  extract-once into filesDir/runtimes/base/<baseId>/rootfs
        v
+---------------------------------------------------------------+
| AstrBot version packages  astrbot-<version>-py312-arm64.tar.zst|
|   wheelhouse for one chosen AstrBot version                    |
+---------------------------------------------------------------+
        |  uv offline install into a per-instance venv
        v
+---------------------------------------------------------------+
| Instance  instances/<id>/                                     |
|   data/  venv/  logs/  backups/  instance.json (port, baseId)  |
+---------------------------------------------------------------+
```

**Why not one full rootfs per version:** a full Debian rootfs per AstrBot version would multiply ~hundreds of MB by every installed version, which is untenable on-device storage with multi-instance use. Instead, one immutable base image is shared by all instances and versions; only the (much smaller) wheelhouse varies per version, and only the venv varies per instance. The cost is that the offline install step must exist and be reliable — which CI smoke-tests (below).

**Offline install command** (run inside PRoot, per instance):

```
uv pip install --no-index --find-links /opt/wheelhouse astrbot==<version>
```

CI **must verify** that the AstrBot wheel ships `dashboard/dist`; a wheelhouse without the dashboard is a failed build, since the WebUI is the app's entire management surface.

**PRoot invocation sketch** (Kotlin; arguments are passed as arrays, never concatenated shell strings):

```
proot --kill-on-exit --link2symlink \
  -0 \
  -r <base rootfs> \
  -b /dev -b /proc -b /sys \
  -b <instance>/data:/opt/astrbot-data \
  -b <instance>/venv:/opt/astrbot-venv \
  -b <shared>/uv-cache:/opt/uv-cache \
  -b <generated>/resolv.conf:/etc/resolv.conf \
  -w /opt/astrbot-data \
  /usr/bin/env \
    ASTRBOT_ROOT=/opt/astrbot-data \
    DASHBOARD_HOST=127.0.0.1 \
    DASHBOARD_PORT=<port> \
    ASTRBOT_DESKTOP_MANAGED=1 \
    ASTRBOT_DESKTOP_SESSION_SECRET=<hex> \
    PYTHONDONTWRITEBYTECODE=1 \
    /opt/astrbot-venv/bin/astrbot run --port <port>
```

Notes: `resolv.conf` is generated per launch from the host's DNS; the bind list is fixed in v1 (no user-defined mounts).

## Multi-instance isolation

| Resource | Scope | Notes |
|---|---|---|
| Data directory | Per instance | `instances/<id>/data`, bind-mounted to `/opt/astrbot-data` |
| venv | Per instance | `instances/<id>/venv`, bind-mounted to `/opt/astrbot-venv` |
| Logs | Per instance | `instances/<id>/logs` |
| Backups | Per instance | `instances/<id>/backups` |
| WebUI port | Per instance | Assigned at creation; validated for conflicts |
| WebUI credentials | Per instance | Random initial password via `ASTRBOT_DASHBOARD_INITIAL_PASSWORD` at `astrbot init -y`; stored in Keystore |
| Process group | Per instance | One PRoot process tree per instance; kill-on-exit contains it |
| Auto-restart policy | Per instance | Off by default; user-enabled per instance |
| Base image | Shared | Read-only **by convention** (never written after extraction) |
| Wheelhouse cache | Shared | `filesDir/wheelhouse`; reused across instances of the same version |
| uv cache | Shared | `UV_LINK_MODE=hardlink` so cache hits don't copy |
| PRoot binaries | Shared | Bundled in the APK |

Operational model: **one foreground service supervises all instances**. Notifications are grouped per instance. Heavy IO operations (installs, restores) are **serialized globally** — one at a time across all instances — so concurrent instance starts never thrash flash storage or starve each other.

## Explicit-install rules

This is the verbatim product policy; the UI and service layer implement exactly this and nothing more:

1. First launch downloads nothing.
2. Base image / version package / per-instance environment installs are **separate user-initiated actions**, each with a confirmed download size.
3. Creating an instance only writes directories and config; its status is **"not installed"** until the user installs the environment.
4. Starting an uninstalled instance only offers **"go install"**.
5. Health checks **report only**; repair is always a user-clicked action.
6. Updates **prompt only**; the app never applies them on its own.
7. The only automatic behaviors are user-enabled **crash auto-restart** and **boot restore**.

## Version catalog & CI

### `catalog.json` schema sketch

```jsonc
{
  "app":     { "minVersion": "1.0.0", "latest": "1.2.0" },
  "bases":   [ { "id": "debian13-py312", "debian": "13", "python": "3.12",
                 "url": "...", "sha256": "...", "size": 0 } ],
  "versions": [ { "version": "v4.x.y", "channel": "stable",
                 "requiresPython": ">=3.12", "url": "...", "sha256": "...",
                 "size": 0, "notesUrl": "...", "minAppVersion": "1.0.0" } ]
}
```

The catalog is **signed (Ed25519/minisign)**; the public key is embedded in the app. **Every download verifies SHA-256 plus signature regardless of source** (GitHub, proxy, or custom mirror). A stale signature check fails closed: no install.

### CI workflows

| Workflow | Runner | Responsibility |
|---|---|---|
| `runtime-base.yml` | ARM64 (`ubuntu-24.04-arm`) | Build the base image `base-<id>-arm64.tar.zst`; **PRoot smoke test** (boot the rootfs, run `python --version` and `uv --version` inside it); sign the artifact. |
| `runtime-versions.yml` | ARM64 | Weekly check of the latest 5 stable AstrBot versions + `workflow_dispatch` for arbitrary versions; build wheelhouse packages; **offline-install smoke test** (`uv pip install --no-index ...` in a clean venv inside PRoot); **`dashboard/dist` presence check**; sign. |
| `android.yml` | x64 | `assembleDebug` + unit tests. (The Android SDK has host limitations on ARM64 Linux, so the APK builds on x64 even though runtime artifacts build on ARM64.) |
| `release.yml` | x64 | Generate + sign `catalog.json`, assemble release APK, publish GitHub Release with NOTICE/source materials. |

## Network sources: preset + custom

Mirrors the AstrBot-Go model: every source has a **connectivity test** before use; failures fall back to the next selected source, never to a silent default.

| Source type | Default | Presets |
|---|---|---|
| GitHub proxy | `https://github.com` | `gh-proxy.com`, `gh-proxy.org`, `hk.gh-proxy.com`, `edgeone.gh-proxy.com`, `gh.llkk.cc` |
| PyPI mirror (online-install fallback) | `https://pypi.org/simple` | Aliyun `https://mirrors.aliyun.com/pypi/simple`, Tencent Cloud `https://mirrors.cloud.tencent.com/pypi/simple`, USTC `https://pypi.mirrors.ustc.edu.cn/simple`, TUNA `https://pypi.tuna.tsinghua.edu.cn/simple`, CERNET `https://mirrors.cernet.edu.cn/pypi/web/simple` |
| Custom artifact base URL | — | User-supplied base URL for self-hosted mirrors of base images / version packages / catalog. |

Node/npm/Python/uv download sources are **intentionally absent**: Python and uv are pinned inside the base image, and AstrBot ships no Node runtime requirement in v1.

## Storage layout

```
filesDir/
  runtimes/
    base/<baseId>/rootfs          # extracted base image; immutable per baseId
  instances/
    <id>/
      instance.json               # name, port, baseId, version, flags
      data/                       # bind-mounted to /opt/astrbot-data
      venv/                       # bind-mounted to /opt/astrbot-venv
      logs/
      backups/
  cache/
    uv/                           # shared uv cache (hardlink mode)
    downloads/                    # in-progress downloads, verified before use
  wheelhouse/
    astrbot-<version>-py312/      # extracted wheelhouses, shared per version
```

`allowBackup=false` on the whole app (and everything under it) so Android backup never copies rootfs/venv blobs or Keystore material. The base image is **immutable per baseId**: a new base image means a new `baseId`, and instance records pin their `baseId` so a base swap never mutates a running instance underneath.

## Security

- **WebUI credentials**: per-instance random initial password (via `ASTRBOT_DASHBOARD_INITIAL_PASSWORD` at `astrbot init -y`) and desktop-session secret, both stored in **Android Keystore**, never in files or `instance.json`.
- **Network**: `DASHBOARD_HOST=127.0.0.1` by default; an explicit per-instance **LAN toggle** (off by default) with a clear warning — v1 ships no HTTPS reverse proxy, so LAN exposure is plaintext by design of the toggle warning.
- **WebView hardened**: host allowlist (only `127.0.0.1:<port>` per running instance), no file access, external links handed to the browser app.
- **Integrity**: all manifests (`catalog.json`) and downloads are signature-verified; a catalog whose signature fails is rejected, not warned about.
- **Logs**: no secrets in logs — env vars carrying secrets are constructed in memory and scrubbed from any diagnostic output.
- **Process handling**: PRoot and child arguments are passed as **arrays** (no shell string concatenation anywhere).
- **Input validation**: instance ids and ports are validated (id charset/length, port range + conflict check) before any path or bind is derived from them.

## Milestones

Single-developer estimate: **~13–15 weeks**.

| Phase | Duration | Exit criteria |
|---|---|---|
| P0 verification | 2 w | Checklist in [docs/P0_VERIFICATION.md](P0_VERIFICATION.md) passes on real ARM64 hardware: PRoot boots the base image, offline install works, AstrBot dashboard reachable in WebView, foreground service survives Doze. targetSdk 37 confirmed, else fall back to 35 and record it. |
| Runtime foundation | 3–4 w | Base image build + PRoot process supervision + per-instance venv/data/port + Keystore credentials. |
| Versions & CI | 3 w | `catalog.json` + signing; `runtime-base.yml` / `runtime-versions.yml` / `release.yml` green; 5 stable wheelhouses published. |
| Flutter UI | 3 w | Instance list/detail, version catalog UI, install flows, WebView management surface; Compose template removed. |
| Hardening & release | 2–3 w | Explicit-install rules audited, security checklist, first GitHub Release with NOTICE materials. |

## Licensing constraints (must-keep)

- **App code (Kotlin/Flutter/build scripts): MIT.**
- **AstrBot upstream: AGPL-3.0-or-later.** Bundling it in shipped runtime artifacts requires source offers/notices in releases; any modifications to AstrBot itself must be published under the same license. We ship it **unmodified** in wheelhouses wherever possible.
- **PRoot: GPL-2.0+.** Bundled binaries keep their license and notice.
- **Debian packages** inside the base image keep their own licenses; the base image is a redistribution and carries Debian's license terms.
- Every release must carry **NOTICE + source-offer materials**. Distribution is GitHub Releases only — **not Google Play**. APK updates verify signing identity before being considered an update.

## Out of scope for v1

- Remote/external instances
- Docker discovery
- NapCat bundling
- SSH / terminal / desktop environment
- Plugin marketplace
- Chat UI
- Scheduled backups
- Instance import/export
- Notification action buttons
- LAN QR codes
