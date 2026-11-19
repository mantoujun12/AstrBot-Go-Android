# P0 Runbook — On-Device Verification Procedure

Step-by-step procedure for running the P0 verification harness on a real
ARM64 device. The harness lives behind the debug-only `p0/run` MethodChannel
(`P0MethodChannel.kt`) and the `DebugP0Page` Flutter page. It refuses all
calls in release builds.

Read [P0_VERIFICATION.md](P0_VERIFICATION.md) first: it defines the go/no-go
items and what evidence to record.

## Prerequisites

- A real ARM64 Android device (minSdk 28; Android 15 noted below).
- USB debugging enabled on the device, `adb` on the host.
- A debug APK built from this repository (`flutter build apk --debug`).
- The base rootfs artifact `rootfs.tar.zst` from the `runtime-base` workflow
  (or a local `runtime/scripts/export-rootfs.sh dist` build).
- The device SHA-256 of the tarball, if you want the harness to verify it
  (optional; the extraction step accepts `sha256Hex` via the channel, the
  page currently passes null).

## Step 1: Install the debug APK

```
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Package name: `io.github.mantoujun12.astrbot_go`.

Confirm the PRoot binaries were extracted next to the APK:

```
adb shell run-as io.github.mantoujun12.astrbot_go ls -l /data/data/io.github.mantoujun12.astrbot_go/app_lib/
```

Expected entries: `libproot.so`, `libproot-loader.so`, `libtalloc.so`,
`libandroid-shmem.so`, `libzstd-jni-1.5.7-28.so` (exact dir name is the
`nativeLibraryDir` shown on the page's Status card; `app_lib` is the usual
suffix for `/data/data/<pkg>`).

## Step 2: Stage the rootfs tarball

Debug builds are `run-as`-able, so push the tarball via `/data/local/tmp`
and copy it into the app's private `files` directory:

```
adb push rootfs.tar.zst /data/local/tmp/rootfs.tar.zst
adb shell run-as io.github.mantoujun12.astrbot_go cp /data/local/tmp/rootfs.tar.zst files/rootfs.tar.zst
adb shell run-as io.github.mantoujun12.astrbot_go ls -l files/
```

The staged path inside the app is
`/data/data/io.github.mantoujun12.astrbot_go/files/rootfs.tar.zst`,
which is the default value of the page's path field.

Optional integrity check from the host:

```
adb shell sha256sum /data/local/tmp/rootfs.tar.zst
```

## Step 3: Extract the base image (harness-side)

In the app (coordinator wires `DebugP0Page` into the debug UI):

1. Open the P0 debug page; the Status card must list the bundled native
   libs from Step 1.
2. Press **Extract base image** with the default path.
   The extraction streams the `.tar.zst` (zstd-jni + commons-compress),
   preserves symlinks/hardlinks/permissions, extracts into a temp dir and
   atomically renames into `files/runtimes/base/p0/rootfs`.
3. On success the Status card shows the extracted rootfs path. A failure
   leaves no partial directory behind (temp dir is deleted).

## Step 4: Run the P0 check presets (items 1-2)

Capture logcat before starting (see Step 6):

| Button | Maps to | Pass criteria |
|---|---|---|
| Item 1: `cat /etc/debian_version && uv --version` | P0 item 1 | exit 0, prints the Debian version and uv version, no SELinux/W^X violations in logcat |
| Item 2a: `python3.12 -c "import ssl, sqlite3"` | P0 item 2 | exit 0, no ImportError |
| Item 2b: `uv venv /opt/astrbot-venv` | P0 item 2 | exit 0, venv created inside the rootfs |

For P0 item 2's offline-install sub-item (`uv pip install --no-index
--find-links /opt/wheelhouse astrbot==<stable>`), stage the wheelhouse the
same way as the tarball (push to `/data/local/tmp`, then `run-as cp`), run a
preset-style free-form command such as:

```
bash -c "uv pip install --no-index --find-links /opt/wheelhouse astrbot==<version> && uv pip list"
```

Free-form input is split on whitespace into an argv array; quoted arguments
with inner spaces are only possible via the presets or a single `bash -c`
argument (there is no host shell anywhere).

Note: P0 item 3 (dashboard reachable) needs a running AstrBot; the P0
harness only covers the smoke commands. The in-app evidence for items 1-2
(exit codes + transcripts) is shown on the page; copy or screenshot it, plus
the logcat capture below.

## Step 5: Re-running

`Extract base image` deletes the previously extracted `rootfs/` and
re-extracts. Everything here is user-initiated; the harness never
downloads or auto-repairs anything.

## Step 6: Capture logcat evidence

```
adb logcat -c
adb logcat -v time > p0-logcat.txt
```

Relevant tags: `P0MethodChannel` (argv of every run; env values are never
logged) plus any SELinux `avc: denied` lines while a preset runs. Keep the
transcript with the exit codes shown on the page as the P0 artifacts.

## Items that remain device-only after this harness

- **P0 item 3** (WebUI dashboard served and reachable in WebView) needs a
  running AstrBot instance; out of scope for the debug harness.
- **P0 items 4-6** (two concurrent instances, WebUI auto-login, process
  lifecycle under Doze/kill) require the P1 foreground service and instance
  manager; not testable with this harness.

## Android 15 seccomp caveat

Android 15 tightened seccomp filters so that some syscalls PRoot relies on
(e.g. `ptrace`-adjacent ones or `close_range`) can be blocked for
untrusted-app processes, causing PRoot to die early with no obvious output.
The harness sets `PROOT_NO_SECCOMP=1` in the PRoot process environment as a
workaround. If item 1 still fails on an Android 15+ device, capture the
logcat excerpt around the failure — it is the input for the targetSdk
37-versus-35 fallback decision in P0_VERIFICATION.md.

## Orphan-process caveat (known limitation)

The harness kills the PRoot process on timeout with `destroyForcibly()`,
but it does not track the full guest child tree. If a run times out,
check for orphans and kill them before the next run:

```
adb shell ps -A | grep -E "proot|python|uv"
```

The real process-group supervisor is P1 work.
