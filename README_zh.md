# AstrBot Go（Android）

[English](./README.md) | [简体中文](./README_zh.md)

一个非官方的第三方 [AstrBot](https://github.com/AstrBotDevs/AstrBot) Android 启动器。AstrBot 是一个多平台 LLM 聊天机器人框架，本应用让它完全运行在你的手机上——基于 PRoot 的 Debian 13（arm64）本地环境，无需 root。

本项目是 [AstrBot-Go](https://github.com/mantoujun12/AstrBot-Go)（基于 Tauri 的桌面启动器）的 Android 姊妹项目。

> **状态：早期开发中。** 本仓库目前不可用。没有发布、没有构建、没有任何保证。非官方第三方项目，与 AstrBot 团队无关，风险自负。官方部署方式请参见 [AstrBot 文档](https://docs.astrbot.app/)。

## 计划架构

- **Flutter UI** + **纯 Kotlin 原生运行时层**。最终应用不使用 Jetpack Compose。
- AstrBot 通过 **PRoot 的 Debian 13（arm64）** 环境在设备本地运行。
- Bootstrap APK 下载两类内容：
  - **基础镜像**（Debian 13 + Python 3.12 + uv），以及
  - 按版本分发的 **AstrBot 离线包（wheelhouse）**，安装到各实例独立的虚拟环境中。
- **多实例启动器**：每个实例拥有独立的数据目录、虚拟环境、端口、日志和备份。
- **一切操作均为显式**：应用绝不自动下载、自动安装或自动升级任何内容，每个操作都由你手动点击完成。
- **WebUI**（聊天、插件、提供商）通过 WebView 内嵌；手机本地运行实例。
- 仅通过 **GitHub Releases** 分发（不上架 Google Play）。**仅支持 ARM64 设备。**

## 计划功能范围

| 方面 | 计划 |
| --- | --- |
| UI | Flutter 前端，Kotlin 原生运行时层 |
| 运行时 | PRoot Debian 13（arm64），Python 3.12 + uv |
| Bootstrap | 基础镜像 + 按版本的 AstrBot 离线包，离线安装 |
| 实例 | 多实例，各自独立的数据目录、虚拟环境、端口、日志、备份 |
| 版本 | 版本选择 UI；CI 预构建最新 5 个 AstrBot 稳定版本，支持按需构建；在线安装为显式的实验性回退方案 |
| 网络源 | 预设 + 自定义（GitHub 代理、PyPI 镜像），带连通性测试，与 AstrBot-Go 的设置保持一致 |
| 更新 | 仅手动——绝不自动 |
| WebUI | 通过 WebView 内嵌（聊天、插件、提供商） |
| 分发 | GitHub Releases，仅 ARM64 |

## 不在范围内

- **远程启动/停止服务器**——手机本地运行实例，远程管理不在范围内。
- Google Play 分发。
- 非 ARM64 设备。

## 许可证

应用代码采用 **MIT** 许可证。

内置运行时镜像分发第三方作品：AstrBot（**AGPL-3.0-or-later**）、PRoot（**GPL**）以及 Debian 软件包。源代码提供方式和许可证声明随每个发布一并提供。
