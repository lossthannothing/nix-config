# AGENTS.md

本文件为 AI 编程助手提供项目上下文和指导。

## 项目概述

这是一个基于 [drupol/infra](https://github.com/drupol/infra) 模式的 NixOS + Home Manager 配置仓库，采用 flake-parts 和模块化架构。

**核心理念**：
- 去中心化：`flake.nix` 只提供机制，不硬编码主机列表
- 分布式注册：每台主机在自己的文件中自注册到 `flake.modules`
- 同位加载：系统层和用户层配置统一管理

## 项目结构

```
nix-config/
├── flake.nix                 # Flake 入口，定义 inputs 和基础配置
├── flake.lock                # 依赖锁定文件
├── apply.sh                  # 交互式多平台部署脚本
├── scripts/                  # 工具脚本（代理、部署辅助）
├── modules/                  # 功能模块（import-tree 自动扫描）
│   ├── base/                 # 基础配置（系统 + 用户）
│   │   ├── facter.nix        # nixos-facter 硬件检测
│   │   ├── home.nix          # HM 基础
│   │   ├── nix.nix           # Nix 守护进程配置
│   │   ├── i18n.nix          # 国际化
│   │   ├── console/          # 控制台配置
│   │   ├── system/           # 系统基础
│   │   └── time/             # 时区
│   ├── dev/                  # 开发工具（自动合并到 homeManager.dev）
│   │   ├── git.nix, direnv.nix, editors.nix, ripgrep.nix ...
│   │   └── languages/        # 语言工具链（rust, go, nix, python, javascript）
│   ├── shell/                # Shell 工具（自动合并到 homeManager.shell）
│   │   └── zsh.nix, starship.nix, fzf.nix, bat.nix, eza.nix ...
│   ├── desktop/              # 桌面环境（HM 合并到 homeManager.desktop，NixOS 各自独立）
│   │   ├── niri.nix          # Niri compositor
│   │   ├── nvidia.nix        # NVIDIA 驱动
│   │   ├── audio.nix         # PipeWire 音频
│   │   ├── fonts.nix         # 系统字体
│   │   └── ...               # waybar, alacritty, theming, screenshot 等
│   ├── wsl/                  # WSL 统一配置（nixos.wsl + homeManager.wsl）
│   │   └── default.nix
│   ├── users/                # 用户特定配置
│   │   └── loss/default.nix  # 用户 loss（nixos.loss + homeManager.loss + meta）
│   └── flake-parts/          # Flake-parts 生成器（架构核心）
│       ├── host-machines.nix # 自动生成 nixosConfigurations/homeConfigurations
│       ├── nixpkgs.nix       # Nixpkgs 配置和 overlays
│       ├── flake-parts.nix   # flake-parts modules 启用
│       ├── fmt.nix           # treefmt-nix 多语言格式化
│       └── flake.nix         # flake.meta 定义
└── hosts/                    # 主机定义（import-tree 自动扫描）
    ├── nixos-wsl/            # NixOS-WSL 完整系统
    │   └── default.nix
    ├── nixos-desktop/        # NixOS 桌面（Niri + NVIDIA）
    │   ├── default.nix
    │   └── facter.json       # 硬件检测报告
    ├── nixos-vm/             # NixOS VM 版本（轻量桌面）
    │   └── default.nix
    └── fedora-wsl/           # Fedora-WSL（仅 Home Manager）
        └── default.nix
```

### 模块架构说明

**模块类型**：
- `flake.modules.nixos.*` - NixOS 系统层配置
- `flake.modules.homeManager.*` - Home Manager 用户层配置
- 同一功能（如 `wsl`）可在一个文件中同时定义两层配置

**自动扫描机制**：
- 通过 `import-tree` 自动扫描 `modules/` 和 `hosts/` 目录
- 所有 `.nix` 文件会自动注册到 `flake.modules` 表
- 主机文件通过 `flake.modules.nixos."hosts/<name>"` 或 `flake.modules.homeManager."hosts/<name>"` 自注册
- `host-machines.nix` 自动过滤 `hosts/` 前缀的模块，生成标准 flake outputs

**Inputs 约束**：
- 所有 flake inputs 必须在 `flake.nix` 中集中声明（Nix 硬性限制）
- 模块通过 `{inputs, ...}:` 参数访问 inputs
- NixOS/HM 模块内部通过 `specialArgs` 获取 inputs

**Desktop 模块特殊模式**：
- HM 侧：所有 desktop/*.nix 的 HM 配置自动合并到 `homeManager.desktop`
- NixOS 侧：各模块注册独立命名空间（`nixos.nvidia`, `nixos.audio` 等），需在 host 中逐一导入

## 开发环境

### 前置要求

- Nix 2.19+ with flakes enabled
- Git
- （WSL）NixOS-WSL 或 NixOS 系统

### 常用命令

```bash
# 检查 Flake 配置
nix flake check

# 更新依赖
nix flake update

# 格式化代码
nix fmt

# 查看可用系统
nix flake show

# 部署到 WSL
sudo nixos-rebuild switch --flake .#nixos-wsl

# 部署桌面
sudo nixos-rebuild switch --flake .#nixos-desktop

# 部署 VM
sudo nixos-rebuild switch --flake .#nixos-vm

# 部署 Home Manager（Fedora-WSL 独立模式）
home-manager switch --flake .#hosts/fedora-wsl

# 测试构建（不激活）
nixos-rebuild build --flake .#nixos-wsl

# 生成硬件检测报告
sudo nix run nixpkgs#nixos-facter -- -o hosts/<hostname>/facter.json
```

### 使用部署脚本

```bash
# 交互式选择部署选项
./apply.sh
```

## 代码风格

### Nix 代码规范

- 使用 `alejandra` 或项目配置的 formatter 格式化代码
- 变量命名：camelCase（函数）、kebab-case（包名）
- 模块定义：明确 `imports`、`options`、`config` 顺序
- 注释：使用 `#` 单行注释，在复杂逻辑前添加说明

### 文件组织

- **一个文件一个职责**：每个模块文件专注单一功能
- **避免循环依赖**：使用 `specialArgs` 或 `config.flake.modules` 引用
- **平台特定配置**：放在 `hosts/` 下，不要混入 `modules/`
- **同位配置优先**：同一功能的系统层和用户层配置放在同一文件

### 示例：创建新模块

```nix
# modules/example/default.nix
{
  flake.modules = {
    # 系统层配置
    nixos.example = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.example-package ];
      services.example.enable = true;
    };

    # 用户层配置
    homeManager.example = { pkgs, ... }: {
      programs.example.enable = true;
      home.packages = [ pkgs.example-tool ];
    };
  };
}
```

## 测试指南

### 本地测试

```bash
# 1. 检查 Flake 语法和评估
nix flake check

# 2. 构建测试（不激活）
nixos-rebuild build --flake .#nixos-wsl

# 3. 检查配置差异
nixos-rebuild dry-run --flake .#nixos-wsl

# 4. 测试特定模块（使用 nix repl）
nix repl
:lf .
:p outputs.nixosConfigurations.nixos-wsl.config.environment.systemPackages
```

### CI/CD

暂无自动化 CI/CD 流程。建议添加：
- GitHub Actions 运行 `nix flake check`
- 定期更新依赖的 workflow

## Git 工作流

### 分支策略

- `master` - 主分支，稳定配置
- `refactor/*` - 重构分支
- `feature/*` - 功能分支

### 提交规范

使用 Conventional Commits：

```
feat: 添加 Rust 开发环境配置
fix: 修复 WSL 路径问题
refactor: 重构为 drupol/infra 模式
docs: 更新 README 说明
chore: 更新 flake inputs
```

### PR 检查清单

- [ ] 运行 `nix flake check` 无错误
- [ ] 代码已格式化（`nix fmt`）
- [ ] 测试配置可正常构建
- [ ] 更新相关文档（README, AGENTS.md）
- [ ] 提交信息符合规范

## 安全与权限

### 允许的自动操作

- 读取项目文件
- 运行 `nix flake check`、`nix fmt`
- 创建或修改 `modules/` 下的模块文件
- 更新文档（README.md, AGENTS.md, CLAUDE.md）

### 需要确认的操作

- 修改 `flake.nix` 或 `flake.lock`
- 添加新的 inputs 依赖
- 修改 `hosts/` 下的主机配置
- 执行 `nixos-rebuild switch` 部署
- 删除文件或模块
- 运行任何可能影响系统的命令

### 禁止的操作

- 自动提交代码或推送到远程仓库
- 执行不可逆的系统更改
- 泄露敏感信息（私钥、密码等）

## 架构参考

本项目架构参考：
- [drupol/infra](https://github.com/drupol/infra) - 核心模式
- [Refactoring my infrastructure-as-code configurations](https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/) - 设计理念

### 关键技术栈

- **Nix Flakes** - 可重复构建
- **flake-parts** - 模块化 Flake 管理（open modules 选项）
- **import-tree** - 自动扫描目录
- **Home Manager** - 用户环境管理
- **NixOS-WSL** - WSL 集成
- **nixos-facter** - 硬件检测（替代 hardware-configuration.nix）
- **rust-overlay** - Rust 工具链
- **treefmt-nix** - 代码格式化
- **Catppuccin** - Mocha 主题系统
- **Niri** - Scrollable-tiling Wayland compositor
- **pkgs-by-name-for-flake-parts** - 自定义包管理（⚠️ 已声明未启用）

## 常见任务

### 添加新软件包

```nix
# 开发工具：创建 modules/dev/<tool>.nix
{
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home.packages = with pkgs; [ new-package ];
  };
}

# Shell 工具：创建 modules/shell/<tool>.nix
{
  flake.modules.homeManager.shell = {
    programs.<tool>.enable = true;
  };
}

# 桌面组件：创建 modules/desktop/<component>.nix
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    programs.<component>.enable = true;
  };
}
```

### 添加新模块

1. 创建 `modules/category/default.nix`
2. 定义 `flake.modules.nixos.*` 和/或 `flake.modules.homeManager.*`
3. 在主机配置中引用该模块
4. 运行 `nix flake check` 验证

### 添加新主机

1. 创建 `hosts/hostname/default.nix`
2. 自注册（选择一种）：
   - 完整 NixOS：`flake.modules.nixos."hosts/hostname" = {...}: { ... };`
   - 仅 HM：`flake.modules.homeManager."hosts/hostname" = {...}: { ... };`
3. 导入所需模块（参考现有 host 配置）
4. 如需硬件检测：`sudo nix run nixpkgs#nixos-facter -- -o hosts/hostname/facter.json`
5. `host-machines.nix` 自动检测 `hosts/` 前缀并注册

## 疑难解答

### 常见问题

**问题：Flake evaluation failed**
- 检查语法错误：`nix flake check`
- 查看详细错误：`nix eval .#nixosConfigurations.nixos-wsl --show-trace`

**问题：模块未被识别**
- 确认文件在 `modules/` 或 `hosts/` 下
- 检查文件是否返回有效的 attrset
- 验证 `import-tree` 是否正确导入

**问题：循环依赖**
- 避免模块间直接 import
- 使用 `config.flake.modules.*` 引用其他模块

**问题：Inputs 无法在模块中声明**
- Nix flake 硬性约束：inputs 必须在 `flake.nix` 中集中声明
- 模块通过 `{inputs, ...}:` 参数访问 inputs
- NixOS/HM 模块通过 `specialArgs` 获取 inputs

## 更多信息

- 项目 README：查看 `README.md`
- NixOS 手册：https://nixos.org/manual/nixos/stable/
- Home Manager 手册：https://nix-community.github.io/home-manager/
- Flake-parts 文档：https://flake.parts/
- import-tree：https://github.com/vic/import-tree
- nixos-facter：https://github.com/numtide/nixos-facter
<!-- TRELLIS:START -->
# Trellis Instructions

These instructions are for AI assistants working in this project.

Use the `/trellis:start` command when starting a new session to:
- Initialize your developer identity
- Understand current project context
- Read relevant guidelines

Use `@/.trellis/` to learn:
- Development workflow (`workflow.md`)
- Project structure guidelines (`spec/`)
- Developer workspace (`workspace/`)

Keep this managed block so 'trellis update' can refresh the instructions.

<!-- TRELLIS:END -->
