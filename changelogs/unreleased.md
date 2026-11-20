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
- Rough launcher UI mirroring the desktop AstrBot-Go layout: desktop-matching theme colors, instance list with status chips, create/edit instance dialogs, instance detail page, three-section versions page, log console with filters, and sectioned settings (general, appearance, network sources, data, about). Driven by clearly-marked mock data until the P1 service layer lands.
- Chat entry pinned to the top of the Instances page: it opens directly with no key required up front; a missing OpenAPI key is surfaced inside the chat page, matching the desktop "enter first, configure later" flow.

## 中文

### 新增

- 以 Flutter 应用外壳替换 Compose 模板，包含早期开发阶段的主页界面。
- 标准 UI 骨架：底部导航切换实例、版本、日志、设置四个占位页面。
- 仅调试构建可用的 P0 验证工具：内置 arm64 PRoot 二进制（Termux 构建）及 Kotlin 通道，可解压暂存的基础镜像并执行 PRoot 冒烟命令；入口位于设置页（仅调试构建）。
- CI：`runtime-base.yml` 在 ARM64 runner 上构建基础镜像并在 PRoot 内冒烟测试（Python 导入、离线 `uv pip install`、Dashboard 资源检查）；`android.yml` 构建调试 APK。
- `docs/P0_RUNBOOK.md` 提供真机验证操作步骤，`docs/legal/THIRD_PARTY_NOTICES.md` 记录内置 PRoot 及原生依赖的许可信息。
- 新增 zstd-jni 与 commons-compress 依赖，用于端上解压 `.tar.zst` 镜像。
- 初版启动器 UI，对齐桌面版 AstrBot-Go 布局：与桌面一致的配色、带状态徽标的实例列表、创建/编辑实例对话框、实例详情页、三段式版本页、带过滤的日志控制台、分节设置页（常规、外观、网络源、数据、关于）。当前由明确标注的模拟数据驱动，待 P1 服务层接入。
- 聊天入口固定在实例页顶部首位：直接进入、无需预配置密钥；实例缺少 OpenAPI 密钥时在聊天页内提示，与桌面版「先进入、后配置」的流程一致。
