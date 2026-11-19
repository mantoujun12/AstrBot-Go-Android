# Unreleased

Working draft. Entries move to `v<version>.md` at release time; pull request
links are added only in the version update. See `AGENTS.md` for the rules.

## English

### Added

- Initial Flutter app shell replacing the Compose template, with an early-development home screen.
- Standard UI skeleton with bottom navigation across Instances, Versions, Logs, and Settings placeholder pages.
- Debug-only P0 verification harness: bundled arm64 PRoot binaries (Termux build) plus a Kotlin channel to extract the staged base rootfs and run the PRoot smoke commands from `docs/P0_VERIFICATION.md`; entry point lives in Settings (debug builds only).
- CI: `runtime-base.yml` builds the base image on an ARM64 runner and smoke-tests it inside PRoot (Python imports, offline `uv pip install`, dashboard assets check); `android.yml` builds the debug APK.
- `docs/P0_RUNBOOK.md` with the on-device verification steps, and `docs/legal/THIRD_PARTY_NOTICES.md` covering the bundled PRoot and native dependencies.
- zstd-jni and commons-compress dependencies for on-device `.tar.zst` rootfs extraction.

## 中文

### 新增

- 以 Flutter 应用外壳替换 Compose 模板，包含早期开发阶段的主页界面。
- 标准 UI 骨架：底部导航切换实例、版本、日志、设置四个占位页面。
- 仅调试构建可用的 P0 验证工具：内置 arm64 PRoot 二进制（Termux 构建）及 Kotlin 通道，可解压暂存的基础镜像并执行 PRoot 冒烟命令；入口位于设置页（仅调试构建）。
- CI：`runtime-base.yml` 在 ARM64 runner 上构建基础镜像并在 PRoot 内冒烟测试（Python 导入、离线 `uv pip install`、Dashboard 资源检查）；`android.yml` 构建调试 APK。
- `docs/P0_RUNBOOK.md` 提供真机验证操作步骤，`docs/legal/THIRD_PARTY_NOTICES.md` 记录内置 PRoot 及原生依赖的许可信息。
- 新增 zstd-jni 与 commons-compress 依赖，用于端上解压 `.tar.zst` 镜像。
