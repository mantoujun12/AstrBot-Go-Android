# P0 On-Device Verification — Go/No-Go

Early-development gate. Run every item below on a **real ARM64 device** with a
debug build of the app. Record the pass/fail verdict, the artifact (log file,
screenshot, APK, etc.) and the device/Android version for each item. Nothing
proceeds past P0 until items 1–4 pass.

## 1. PRoot executes the base image

- **Setup:** PRoot + its loader shipped as jniLibs
  (`jniLibs.useLegacyPackaging = true`, so the binaries land uncompressed on
  disk and stay executable). Build against **targetSdk 37**; if blocked, fall
  back to targetSdk 35 (proven by the reference implementation
  JunWan666/astrbot-for-android).
- **Pass criteria:** `proot -r <extracted-rootfs> /bin/bash -c "cat /etc/debian_version && uv --version"`
  completes inside the app process with exit code 0 and no SELinux/W^X
  violations in logcat.
- **Artifact:** logcat capture of the PRoot invocation + terminal transcript.

## 2. Python and offline installs work inside PRoot

- **Pass criteria, all inside PRoot:**
  - `python3.12 -c "import ssl, sqlite3"` exits 0.
  - `uv venv /opt/astrbot-venv` creates a usable venv.
  - `uv pip install --no-index --find-links /opt/wheelhouse astrbot==<stable>`
    completes offline (airplane mode / Wi-Fi off) against a locally staged
    wheelhouse.
- **Artifact:** full command transcript incl. `uv pip list` output.

## 3. AstrBot wheel ships the WebUI

- **Pass criteria:** the installed AstrBot wheel contains `dashboard/dist`
  (WebUI static assets), and `http://127.0.0.1:<port>` serves the dashboard
  (static files resolve, no 404s on core assets).
- **Artifact:** the exact wheel URL and SHA-256 used, plus a screenshot of the
  loading dashboard.

## 4. Two concurrent instances are fully isolated

- **Setup:** launch two AstrBot instances on distinct ports with per-instance
  bind mounts for `/tmp`, `/root`, `/var/tmp`, `/run`, `/opt/astrbot-data`,
  `/opt/astrbot-venv`, `/opt/uv-cache`, and `PYTHONDONTWRITEBYTECODE=1`.
- **Pass criteria:** no cross-instance writes (verify by diffing the mounted
  dirs before/after); each instance only listens on its own port; data, config
  and logs stay isolated; both instances stay healthy for 10+ minutes.
- **Artifact:** `ss -tlnp`/netstat output per instance + directory diff
  showing zero cross-contamination.

## 5. WebUI auto-login from the app

- **Pass criteria:** with `ASTRBOT_DESKTOP_MANAGED=1` and
  `ASTRBOT_DESKTOP_SESSION_SECRET` set in the instance env, a loopback
  `POST /api/v1/auth/desktop-session` with the `X-AstrBot-Desktop-Session`
  header yields a session the WebView can use; cookie injection works over
  `http://127.0.0.1`. If cookie injection fails, fall back to password
  autofill and record that the fallback was needed.
- **Artifact:** transcript of the desktop-session POST + a logged-in dashboard
  screenshot (either path).

## 6. Process lifecycle and survival

- **Kill test:** terminate the app process; **pass** if no orphan
  PRoot/uvicorn children remain (`ps` shows none after a few seconds) and the
  ports are freed. If leaks appear, switch to a native process-group runner
  (e.g. `setsid`-style kill of the whole group) and re-test.
- **Screen-off test:** with the screen off for 30 minutes, the instance
  survives via a foreground service + wakelock; the dashboard still responds
  on wake.
- **Artifact:** before/after process listings and a post-wake dashboard
  screenshot, with timestamps.

## Go/no-go

- **Items 1–4 are hard gates.** If any of them fails and cannot be resolved by
  lowering targetSdk (37 → 35) or switching to per-instance rootfs copies
  (instead of a shared read-only rootfs), **stop and re-plan** — the PRoot
  architecture is not viable on this target and the design must be revisited
  before any further work.
- Items 5–6 are required for release but may be iterated on after P0 passes,
  since they have recorded fallbacks (password autofill; process-group
  runner).
- Record the final verdict, date, device model, and Android version at the
  top of this file once the run is complete.
