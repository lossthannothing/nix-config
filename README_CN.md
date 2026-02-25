# nix-config

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md) [![简体中文](https://img.shields.io/badge/lang-简体中文-red.svg)](README_CN.md)

个人 NixOS 和 Home Manager 配置，灵感来自 [drupol/infra](https://github.com/drupol/infra) 模块化架构模式。

## 架构概览

本配置采用由 `flake-parts` 和 `import-tree` 驱动的**去中心化模块系统**：

```
┌─────────────────────────────────────────────────────────┐
│  flake.nix（机制层）                                    │
│  ┌─────────────────────────────────────────────────┐  │
│  │  inputs: 所有外部依赖（必须集中声明）          │  │
│  │  import-tree 自动扫描                          │  │
│  │  - ./modules/*  → 注册到 flake.modules        │  │
│  │  - ./hosts/*    → 注册到 nixosConfigurations  │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  modules/（能力层）                                     │
│  ┌─────────────────────────────────────────────────┐  │
│  │  flake.modules.nixos.*        (系统级配置)   │  │
│  │  flake.modules.homeManager.*  (用户级配置)   │  │
│  └─────────────────────────────────────────────────┘  │
│           ↓                    ↓                     │
│  dev/, shell/, base/, desktop/, wsl/, users/        │
│  (自动合并到聚合模块)                                 │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  hosts/（实例层）                                       │
│  ┌─────────────────────────────────────────────────┐  │
│  │  nixos-wsl/      → NixOS-WSL                │  │
│  │  nixos-desktop/  → NixOS Desktop (Niri+NVIDIA)│  │
│  │  nixos-vm/       → NixOS VM (轻量桌面)      │  │
│  │  fedora-wsl/     → Fedora-WSL (仅 HM)       │  │
│  └─────────────────────────────────────────────────┘  │
│  通过 imports 组装 modules 中的能力                  │
└─────────────────────────────────────────────────────────┘
```

### 核心原则

1. **去中心化**：`flake.nix` 提供机制，而非硬编码的主机列表
2. **分布式注册**：每个主机通过 `flake.modules` 自行注册
3. **同位配置**：系统和用户配置按功能统一管理
4. **自动合并**：`dev/` 和 `shell/` 模块自动聚合

### 模块自动合并规则

| 目录 | 模块路径 | 描述 |
|-----------|-------------|-------------|
| `modules/dev/*.nix` | `homeManager.dev` | 开发工具（自动合并，14 文件） |
| `modules/shell/*.nix` | `homeManager.shell` | Shell 工具（自动合并，11 文件） |
| `modules/desktop/*.nix` | `homeManager.desktop` | 桌面环境配置（自动合并，14+ 文件） |

**注意**：向 `dev/` 或 `shell/` 添加工具时，只需创建文件 —— 无需修改主机配置！

## 技术栈

| 技术 | 角色 | 状态 |
|------------|------|--------|
| Nix Flakes | 可重复、声明式构建 | ✅ 核心 |
| flake-parts | 模块框架，通过 `flakeModules.modules` 启用 open module 选项 | ✅ 核心 |
| import-tree | 递归扫描 `modules/` 和 `hosts/`，自动 import 所有 .nix 文件 | ✅ 核心 |
| Home Manager | 用户级包和配置管理，支持 NixOS 集成和独立模式 | ✅ 核心 |
| nixos-facter | 硬件检测，替代传统 hardware-configuration.nix | ✅ desktop |
| disko | 声明式磁盘分区，自动生成 fileSystems | ✅ 核心 |
| treefmt-nix | 多语言格式化（alejandra/deadnix/statix/shfmt/rustfmt/black/biome） | ✅ |
| Catppuccin | Mocha 配色主题系统，通过 catppuccin/nix 集成 | ✅ desktop |
| Niri | Scrollable-tiling Wayland compositor | ✅ desktop |
| NixOS-WSL | NixOS 在 WSL2 上的集成 | ✅ wsl |
| rust-overlay | Rust 工具链管理 | ✅ |
| nixos-anywhere | 通过 SSH 远程安装 NixOS | ✅ 部署 |

## 目录结构

```
nix-config/
├── flake.nix              # Flake 入口
├── flake.lock             # 依赖锁定文件
├── CLAUDE.md              # Claude AI 助手上下文
├── README.md              # 英文文档
├── README_CN.md           # 中文文档（本文件）
├── scripts/               # 工具脚本
│   ├── deploy.sh         # Live USB (disko) & 远程 (nixos-anywhere) 部署
│   ├── nix-proxy.sh      # Nix 代理助手
│   ├── proxy-wrapper.sh  # 网络操作的代理包装器
│   └── set-proxy.sh      # 代理环境设置
├── modules/               # 功能模块（自动扫描）
│   ├── base/              # 基础系统 + 用户配置
│   │   ├── console/       # 控制台设置
│   │   ├── system/        # 系统包
│   │   ├── time/          # 时区 & 语言
│   │   ├── disko.nix      # 声明式磁盘分区
│   │   ├── facter.nix     # nixos-facter 集成
│   │   ├── home.nix       # Home Manager 基础配置
│   │   ├── i18n.nix       # 国际化
│   │   └── nix.nix        # Nix 守护进程设置
│   ├── dev/               # 开发工具（自动合并）
│   │   ├── languages/     # 语言工具链
│   │   │   ├── go.nix
│   │   │   ├── javascript.nix
│   │   │   ├── nix.nix
│   │   │   ├── python.nix
│   │   │   └── rust.nix   # Rust overlay 注入
│   │   ├── tools/
│   │   │   └── devenv.nix
│   │   ├── ansible.nix    # 配置管理
│   │   ├── claude.nix     # Claude Code
│   │   ├── direnv.nix     # 每目录环境
│   │   ├── editors.nix    # 代码编辑器
│   │   ├── git.nix        # Git 配置
│   │   ├── hyperfine.nix  # 性能测试
│   │   ├── just.nix       # 任务运行器
│   │   └── ripgrep.nix    # 快速搜索 (rg)
│   ├── shell/             # Shell 工具（自动合并）
│   │   ├── archive.nix    # 归档处理 (extract)
│   │   ├── bat.nix        # 带语法高亮的 cat
│   │   ├── eza.nix        # 带集成的 ls
│   │   ├── fd.nix         # find 替代品
│   │   ├── fzf.nix        # 模糊搜索器
│   │   ├── nix-your-shell.nix  # Nix shell 集成
│   │   ├── starship.nix   # 跨 shell 提示符
│   │   ├── zoxide.nix     # cd 替代品 (z/cdi)
│   │   └── zsh.nix        # Zsh 配置
│   ├── desktop/           # 桌面环境
│   │   ├── alacritty.nix  # 终端模拟器
│   │   ├── audio.nix      # PipeWire 音频
│   │   ├── bluetooth.nix  # 蓝牙支持
│   │   ├── browser.nix    # 浏览器配置
│   │   ├── fcitx5.nix     # 输入法 (NixOS + HM)
│   │   ├── fonts.nix      # 字体配置
│   │   ├── fuzzel.nix     # 应用启动器
│   │   ├── media.nix      # 媒体应用
│   │   ├── niri.nix       # Wayland 合成器
│   │   ├── nvidia.nix     # NVIDIA 驱动
│   │   ├── power.nix      # 电源管理
│   │   ├── screenshot.nix # 截屏工具
│   │   ├── swayidle.nix   # 空闲管理
│   │   ├── swaylock.nix   # 屏幕锁定 (PAM)
│   │   ├── swww.nix       # 壁纸守护进程
│   │   ├── theming.nix    # Catppuccin 主题
│   │   ├── waybar.nix     # 状态栏
│   │   ├── wired-notify.nix  # 通知守护进程
│   │   └── wlogout.nix    # 注出菜单
│   ├── wsl/               # WSL 统一配置
│   │   └── default.nix    # nixos.wsl + homeManager.wsl
│   ├── users/             # 用户特定配置
│   │   └── loss/
│   │       └── default.nix    # nixos.loss + homeManager.loss
│   └── flake-parts/       # Flake-parts 生成器
│       ├── flake-parts.nix
│       ├── flake.nix
│       ├── fmt.nix        # 代码格式化
│       ├── host-machines.nix  # 自动生成配置
│       └── nixpkgs.nix        # Nixpkgs 配置 + overlays
└── hosts/                 # 主机定义（自动扫描）
    ├── nixos-wsl/         # NixOS-WSL
    ├── nixos-desktop/     # NixOS 桌面 (Niri + NVIDIA + Catppuccin)
    ├── nixos-vm/          # NixOS VM (轻量桌面)
    └── fedora-wsl/        # Fedora-WSL (仅 Home Manager)
```

## 快速开始

### 前置要求

- Nix 2.19+ 启用 flakes
- Git
- NixOS 或 NixOS-WSL

### 安装

1. 克隆此仓库：
```bash
git clone https://github.com/lossthannothing/nix-config.git
cd nix-config
```

2. 部署到你的系统：
```bash
# 对于 NixOS-WSL
sudo nixos-rebuild switch --flake .#nixos-wsl

# 对于 NixOS 桌面
sudo nixos-rebuild switch --flake .#nixos-desktop

# 仅 Home Manager（如 Fedora-WSL）
home-manager switch --flake .#hosts/fedora-wsl

# 本地安装（通过 Live USB，使用 disko）
./scripts/deploy.sh --local nixos-desktop

# 远程安装（使用 nixos-anywhere）
./scripts/deploy.sh nixos-vm 192.168.122.100
```

### 常用命令

```bash
# 检查 flake 配置
nix flake check

# 格式化代码（alejandra, deadnix, statix 等）
nix fmt

# 更新依赖
nix flake update

# 显示可用系统
nix flake show

# 构建但不激活
nixos-rebuild build --flake .#nixos-wsl

# 测试配置
nixos-rebuild dry-run --flake .#nixos-wsl

# 使用 nix repl 调试
nix repl
:lf .
:p outputs.nixosConfigurations.nixos-wsl.config.services
```

## 现代工具链

| 传统命令 | 现代替代 | 配置位置 |
|-------------|--------|-----------------|
| `find` | `fd` | `modules/shell/fd.nix` |
| `grep` | `rg` (ripgrep) | `modules/dev/ripgrep.nix` |
| `ls` | `eza` | `modules/shell/eza.nix` |
| `cat` | `bat` | `modules/shell/bat.nix` |
| `cd` | `z` (zoxide) | `modules/shell/zoxide.nix` |
| `tree` | `eza --tree` | `modules/shell/eza.nix` |

### 使用示例
```bash
fd --extension nix        # 查找 .nix 文件
rg "flake.modules"        # 搜索文本
eza --tree --level=3      # 目录树
```

## 配置指南

### 模块命名空间注册表

**NixOS 命名空间**（需要在 hosts 中显式导入）：
| 命名空间 | 来源 | 描述 |
|-----------|--------|-------------|
| `nixos.base` | `base/*.nix` | 多文件自动合并 |
| `nixos.facter` | `base/facter.nix` | 硬件检测 |
| `nixos.disko` | `base/disko.nix` | 声明式分区 |
| `nixos.rust` | `dev/languages/rust.nix` | Rust overlay |
| `nixos.wsl` | `wsl/default.nix` | WSL 系统配置 |
| `nixos.loss` | `users/loss/default.nix` | 用户系统配置 |
| `nixos.nvidia` | `desktop/nvidia.nix` | NVIDIA 驱动 |
| `nixos.niri` | `desktop/niri.nix` | Wayland 合成器 |
| `nixos.audio` | `desktop/audio.nix` | PipeWire 音频 |
| `nixos.bluetooth` | `desktop/bluetooth.nix` | 蓝牙 |
| `nixos.power` | `desktop/power.nix` | 电源管理 |
| `nixos.fcitx5` | `desktop/fcitx5.nix` | 输入法 |
| `nixos.swaylock` | `desktop/swaylock.nix` | PAM 认证 |
| `nixos.fonts` | `desktop/fonts.nix` | 系统字体 |

**Home Manager 命名空间**：
| 命名空间 | 来源 | 描述 |
|-----------|--------|-------------|
| `homeManager.base` | `base/home.nix`, `base/nix.nix` | 多文件自动合并 |
| `homeManager.shell` | `shell/*.nix` (11 文件) | 自动合并 |
| `homeManager.dev` | `dev/*.nix` (14 文件) | 自动合并 |
| `homeManager.desktop` | `desktop/*.nix` (14+ 文件) | 自动合并 |
| `homeManager.wsl` | `wsl/default.nix` | WSL 用户配置 |
| `homeManager.loss` | `users/loss/default.nix` | 用户 HM 配置 |

### 添加开发工具

```nix
# 创建 modules/dev/<tool>.nix（仅此一步！）

# 情况1：有 programs.<tool>.enable
{
  flake.modules.homeManager.dev = {
    programs.<tool> = {enable = true;};
  };
}

# 情况2：无 Home Manager 支持
{
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home.packages = with pkgs; [<tool>];
  };
}
```

### 添加 Shell 工具

```nix
# 创建 modules/shell/<tool>.nix

# 情况1：有 programs.<tool>.enable
{
  flake.modules.homeManager.shell = {
    programs.<tool> = {enable = true;};
  };
}

# 情况2：无 Home Manager 支持
{
  flake.modules.homeManager.shell = {pkgs, ...}: {
    home.packages = with pkgs; [<tool>];
  };
}
```

### 添加桌面组件

```nix
# 创建 modules/desktop/<component>.nix

# 情况1：仅 HM 配置（自动合并到 homeManager.desktop）
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    programs.<component>.enable = true;
  };
}

# 情况2：需要 NixOS + HM 双重注册
{
  flake.modules = {
    nixos.<component> = { /* 系统级配置 */ };
    homeManager.desktop = { /* 用户级配置，自动合并 */ };
  };
}
# 注意：NixOS 侧需在 hosts/nixos-desktop/default.nix 中手动导入
```

### 添加新主机

```nix
# 1. 创建 hosts/<hostname>/default.nix
# 2. 选择注册模式：
#    - 完整 NixOS: flake.modules.nixos."hosts/<hostname>" = {...}: { ... };
#    - 仅 HM:     flake.modules.homeManager."hosts/<hostname>" = {...}: { ... };
# 3. 导入所需模块（参考现有主机）
# 4. 如需硬件检测：sudo nix run nixpkgs#nixos-facter -- -o hosts/<hostname>/facter.json
# 5. host-machines.nix 自动检测 "hosts/" 前缀并注册到配置
```

### 硬件检测 (nixos-facter)

替代传统 `hardware-configuration.nix`：
- `modules/base/facter.nix`：注册 `nixos.facter` 模块，安装 facter CLI
- `hosts/nixos-desktop/facter.json`：硬件检测报告
- 在 host 中引用：`{hardware.facter.reportPath = ./facter.json;}`
- 生成命令：`sudo nix run nixpkgs#nixos-facter -- -o hosts/<hostname>/facter.json`
- **仅 desktop/VM host 使用**，WSL 不需要（硬件由 Windows 管理）

## 部署命令

```bash
# NixOS 系统部署
sudo nixos-rebuild switch --flake .#nixos-wsl         # 部署 WSL
sudo nixos-rebuild switch --flake .#nixos-desktop      # 部署桌面
sudo nixos-rebuild switch --flake .#nixos-vm           # 部署 VM

# Home Manager 独立部署
home-manager switch --flake .#hosts/fedora-wsl         # 部署独立 HM

# Live USB 安装（disko - 声明式分区）
./scripts/deploy.sh --local nixos-desktop

# 远程部署（nixos-anywhere）
./scripts/deploy.sh nixos-vm 192.168.122.100
```

## 平台支持

当前配置：

| 主机 | 类型 | 平台 | 描述 |
|------|------|----------|-------------|
| nixos-wsl | NixOS | x86_64-linux | 主要开发环境 |
| nixos-desktop | NixOS | x86_64-linux | 完整桌面 (Niri + NVIDIA + Catppuccin) |
| nixos-vm | NixOS | x86_64-linux | 轻量级测试 VM |
| fedora-wsl | 仅 HM | x86_64-linux | Fedora WSL + Home Manager |

## 项目哲学

本配置遵循以下原则：

1. **模块化**：每个模块自包含且可复用
2. **可组合性**：自由组合模块，无耦合
3. **简洁性**：清晰结构，最少抽象
4. **DRY**：自动合并和模块注册消除重复
5. **可维护性**：易于理解和修改
6. **最佳实践**：遵循 NixOS 和 Nix 社区标准

## 文档

- **[CLAUDE.md](./CLAUDE.md)** - 详细的项目架构和模式（中文）
- **[NixOS Options](https://search.nixos.org/options)** - 官方 NixOS 选项搜索
- **[Nix Packages](https://search.nixos.org/packages)** - Nixpkgs 包搜索
- **[Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)** - HM 选项
- **[Flake-parts](https://flake.parts/)** - Flake-parts 文档
- **[import-tree](https://github.com/vic/import-tree)** - 自动扫描工具
- **[nixos-facter](https://github.com/numtide/nixos-facter)** - 硬件检测
- **[disko](https://github.com/nix-community/disko)** - 声明式分区
- **[nixos-anywhere](https://github.com/nix-community/nixos-anywhere)** - 远程安装

## 灵感来源

本项目灵感来自：

- **[drupol/infra](https://github.com/drupol/infra)** - 去中心化模块架构
- **[Refactoring my infrastructure-as-code configurations](https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/)** - 设计哲学

## 贡献

这是个人配置仓库。欢迎：

- Fork 并根据你的需求调整
- 报告问题或提出改进建议
- 分享你自己的模式和想法

## 许可证

本项目采用 MIT 许可证。详见 LICENSE。

## 作者

**loss** - [GitHub](https://github.com/lossthannothing)

---

**注意**：此配置为个人使用定制。在部署到你自己的系统前，请查看并调整设置。
