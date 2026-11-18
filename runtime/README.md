# AstrBot PRoot Base Image

This directory holds the base rootfs used by the Android app to run AstrBot
inside a PRoot environment on the phone.

## What the base image is

- Debian 13 (trixie), arm64.
- uv + a pinned standalone CPython 3.12 (python-build-standalone, uv-managed)
  installed under `/opt/python`.
- Base libraries AstrBot needs: ffmpeg, libgomp1, OpenSSL/ffi/sqlite/zlib dev
  headers, git, zstd, and standard tooling.

## What it deliberately does NOT include

- **No AstrBot.** App version packages are wheelhouse tarballs (AstrBot version
  + all cp312/aarch64 wheels) installed offline into per-instance venvs with
  `uv pip install --no-index --find-links`.
- **No wheelhouse.** `/opt/wheelhouse` is an empty mount point, bind-mounted
  per instance at runtime.
- **No `/etc/resolv.conf`.** The app regenerates it per instance from Android's
  system DNS configuration.
- All of `/opt/astrbot-data`, `/opt/astrbot-venv`, `/opt/wheelhouse` and
  `/opt/uv-cache` are empty mount points, bind-mounted per instance.

Everything is user-initiated; the app never auto-installs anything.

## Local build

Prerequisite on x86_64 hosts — install qemu user emulation once:

```sh
docker run --privileged --rm tonistiigi/binfmt --install arm64
```

Then, from the repo root:

```sh
runtime/scripts/export-rootfs.sh dist          # or: export-rootfs.sh dist --force
```

This builds the image with `docker buildx build --platform linux/arm64`,
exports the rootfs tree, and produces `dist/rootfs.tar.zst`,
`dist/rootfs.tar.zst.sha256` and a `manifest.json` stub.

## Release builds

Release builds run on GitHub Actions ARM64 runners (`ubuntu-24.04-arm`), so
no emulation is needed there. This scaffolding is **pending P0 on-device
verification** — see [docs/P0_VERIFICATION.md](../docs/P0_VERIFICATION.md)
for the go/no-go checklist.

## Security and integrity

- All toolchain versions are pinned (Debian release, uv release, CPython
  patch version) in `Dockerfile.base`.
- Every published rootfs ships a SHA-256 manifest (`rootfs.tar.zst.sha256` +
  `manifest.json`); the app verifies the archive hash before first use.
- Version packages (wheelhouses) are distributed through a signed catalog;
  wheel URLs and hashes are recorded at build time.
