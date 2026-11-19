# Third-Party Notices

Bundled third-party components of the AstrBot-Go-Android APK, plus the
Maven dependencies that compile into it. Every release must carry this
notice plus the corresponding license texts and, for (L)GPL components, a
written source offer (see "Release obligations" below).

Later entries must follow the same per-component structure.

## PRoot

- **Component:** PRoot (user-space implementation of chroot, `chdir`,
  `mount --bind`, and binfmt_misc)
- **Version:** 5.1.107.102 (Termux build, `proot_5.1.107.102_aarch64.deb`)
- **Source (downloaded 2026-11-19):**
  https://packages.termux.dev/apt/termux-main/pool/main/p/proot/proot_5.1.107.102_aarch64.deb
  - Termux apt repo: https://packages.termux.dev/apt/termux-main/
  - Upstream project: https://proot-me.github.io/ (license: GPL-2.0-or-later)
- **APK files:**
  - `jniLibs/arm64-v8a/libproot.so` — the `usr/bin/proot` binary
  - `jniLibs/arm64-v8a/libproot-loader.so` — the `usr/libexec/proot/loader`
    guest loader, passed to PRoot at runtime via `PROOT_LOADER`
  - `loader32` from the package is not shipped (arm64-only guest);
    upstream also embeds the guest loader separately.
- **Modifications (must be kept with the source offer):** the `libproot.so`
  binary is byte-patched from the package original (SHA-256
  `3621937c1c5a98d0d39ca599af573a6bc15128690606d535e8b05da00cec4f41`):
  the single ELF `.dynstr` occurrence of the `DT_NEEDED` name
  `libtalloc.so.2` at file offset 7116 was replaced with `libtalloc.so`
  (null-padded to the same length), so the Android dynamic linker can
  resolve the bundled `jniLibs` copy; Android only extracts/keeps exec
  permission for `lib*.so`-named entries. No other bytes were changed
  (patched SHA-256
  `aad737c5b546ee7471f133be90ef20f765aa98a303522557ceed3dff76605085`).
  Reproduction: download the .deb above, `tar -xf` the .deb and its
  `data.tar.xz`, and apply the 14-byte replacement at offset 7116 of
  `data/data/com.termux/files/usr/bin/proot`.
- **Unverified locally:** the hard-coded `DT_RUNPATH`
  `/data/data/com.termux/files/usr/lib` and the default loader path inside
  the binary. `LD_LIBRARY_PATH` (searched before `DT_RUNPATH`) plus
  `PROOT_LOADER` override both at runtime, but this is only provable on a
  device; see docs/P0_RUNBOOK.md.
- **License:** GPL-2.0-or-later. Obligations: keep this notice, keep the
  license text, and offer the corresponding source (upstream PRoot plus
  this modification) with every release that ships the binary.

## libtalloc (Samba)

- **Component:** talloc hierarchical memory allocator, dynamically linked
  by PRoot
- **Version:** 2.5.0 (Termux build, `libtalloc_2.5.0_aarch64.deb`)
- **Source (downloaded 2026-11-19):**
  https://packages.termux.dev/apt/termux-main/pool/main/libt/libtalloc/libtalloc_2.5.0_aarch64.deb
  - Upstream: https://www.samba.org/ftp/talloc/
- **APK file:** `jniLibs/arm64-v8a/libtalloc.so` — the package's
  `usr/lib/libtalloc.so.2.5.0` renamed (see the PRoot entry above; the
  patched `DT_NEEDED` matches this name).
- **License:** LGPL-3.0-or-later per upstream's talloc `LICENSE` (the
  Termux package's `copyright` symlink points at `LICENSES/GPL-3.0.txt`,
  reflecting Samba's dual GPL-3.0/LGPL-3.0 contribution grant; upstream
  distributes the library under LGPL-3.0-or-later). Unmodified binary.
  Obligations: keep the license text and provide the corresponding source
  offer; LGPL also requires the ability to relink against a modified
  library, satisfied by shipping the .so as a discrete APK entry.

## libandroid-shmem (Termux)

- **Component:** System V shared memory emulation on Android, dynamically
  linked by PRoot
- **Version:** 0.7 (Termux build, `libandroid-shmem_0.7_aarch64.deb`)
- **Source (downloaded 2026-11-19):**
  https://packages.termux.dev/apt/termux-main/pool/main/liba/libandroid-shmem/libandroid-shmem_0.7_aarch64.deb
  - Upstream: https://github.com/termux/libandroid-shmem
- **APK file:** `jniLibs/arm64-v8a/libandroid-shmem.so` — unmodified
  `usr/lib/libandroid-shmem.so`.
- **License:** BSD-2-Clause (Copyright (c) 2013 Sergii Pylypenko,
  (c) 2017 Fredrik Fornwall). Obligation: retain this notice and the
  license text.

## zstd-jni

- **Component:** Java/JNI bindings for the Zstandard compressor; used by
  the Kotlin layer to decompress the `.tar.zst` base image
- **Version:** 1.5.7-28
- **Source:** https://repo1.maven.org/maven2/com/github/luben/zstd-jni/1.5.7-28/
  (declared as the Gradle dependency `com.github.luben:zstd-jni:1.5.7-28`)
- **APK files:** the Java classes from the jar, plus
  `jniLibs/arm64-v8a/libzstd-jni-1.5.7-28.so`, which is an unmodified copy
  of the jar's `linux/aarch64/libzstd-jni-1.5.7-28.so` native library.
  AGP does not package the jar's desktop-layout natives, so the .so is
  copied into `jniLibs` manually; the library's own loader then finds it
  via `System.loadLibrary("zstd-jni-1.5.7-28")` after classpath extraction
  fails under Android's W^X restrictions.
- **License:** BSD-2-Clause OR GPL-2.0 (upstream dual license,
  https://github.com/luben/zstd-jni). Obligation: retain this notice and
  the license text.

## Apache Commons Compress

- **Component:** tar/zstd archive handling used by the Kotlin layer to
  extract the base rootfs (symlinks, hardlinks, long names, permissions)
- **Version:** 1.28.0
- **Source:**
  https://repo1.maven.org/maven2/org/apache/commons/commons-compress/1.28.0/
  (declared as the Gradle dependency
  `org.apache.commons:commons-compress:1.28.0`)
- **APK file:** compiled into the APK by AGP; no separate native binary.
- **License:** Apache-2.0 (Copyright 2002-2026 The Apache Software
  Foundation). Obligation: retain this notice and reproduce the NOTICE
  file shipped with Apache Commons Compress in release materials.

## Release obligations (summary)

1. Every GitHub Release must carry the license texts for all entries above
   and the Apache NOTICE file for Commons Compress.
2. GPL/LGPL components (PRoot with the byte patch above, libtalloc,
   optionally zstd-jni under GPL-2.0) require a written offer of the
   corresponding machine-readable source with the APK.
3. AstrBot itself (AGPL-3.0-or-later) ships unmodified inside downloaded
   runtime artifacts, not inside the APK; its notice and source offer are
   tracked separately with the runtime artifacts.
4. Debian packages inside the base image keep their own licenses; the base
   image is a redistribution and documents its package manifest.
