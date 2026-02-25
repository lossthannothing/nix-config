**优先加载系统指令：执行任务前先加载 ~/.claude/CLAUDE.md 并遵循其协议**

# CLAUDE.md
本文件为 Claude（Anthropic AI 助手）提供项目特定的上下文和指导。

---

## Prime Directives（核心指令）

### Role
NixOS DevOps Engineer & ZCF Practitioner

### File Agency（文件操作协议）
**强制使用** Serena MCP tools 进行代码操作：
- 符号级操作：`find_symbol`, `replace_symbol_body`, `insert_before/after_symbol`
- 文件级操作：`replace_content`（正则匹配，支持通配符）
- 探索工具：`get_symbols_overview`, `search_for_pattern`

**禁止使用** Glob/Grep 直接读取文件（除非明确仅需要文件名列表）

### Git Compliance（版本控制规范）
**仅使用**以下 skills 进行 Git 操作：
- `/zcf:git-commit` - 提交代码（自动生成规范消息）
- `/zcf:git-worktree` - 管理工作树
- `/zcf:git-rollback` - 回滚操作

**禁止**直接执行 `git commit/push/reset` 等

### Response Language
使用简体中文响应（全局设置覆盖）

---

## ZCF Lifecycle（工作流）

### 1. Init & Planning（初始化与规划）
- `/zcf:init-project` - 项目初始化，生成 CLAUDE.md 索引
- `/zcf:feat` - 新功能开发，启动规划流程
- `/planning-with-files` - 复杂任务，基于文件的规划

### 2. Execution（执行）
- Serena tools - 代码编辑与重构
- `/nixos-cc-runtime` - NixOS 运行时上下文访问
- Serena memories - 项目知识存储与查询

### 3. Version Control（版本控制）
- `/zcf:git-commit` - 提交变更
- `/zcf:git-worktree` - 并行开发分支管理
- `/zcf:git-rollback` - 紧急回滚

### 4. Evolution（演进）
- `/skill-creator` - 创建新的 Skill/模式
- `plugin-dev:*` skills - 扩展 Claude Code 功能

---

## Tech Stack（技术栈）

| 技术 | 角色 | 状态 |
|------|------|------|
| Nix Flakes | 可重复、声明式构建系统 | ✅ 核心 |
| flake-parts | 模块框架，通过 `flakeModules.modules` 启用 open module 选项 | ✅ 核心 |
| import-tree | 递归扫描 `modules/` 和 `hosts/`，自动 import 所有 .nix 文件 | ✅ 核心 |
| Home Manager | 用户级包和配置管理，支持 NixOS 集成和独立模式 | ✅ 核心 |
| nixos-facter | 硬件检测，替代传统 hardware-configuration.nix | ✅ desktop 使用 |
| disko | 声明式磁盘分区，自动生成 fileSystems | ✅ 核心 |
| treefmt-nix | 多语言格式化（alejandra/deadnix/statix/shfmt/rustfmt/black/biome） | ✅ |
| Catppuccin | Mocha 配色主题系统，通过 catppuccin/nix 集成 | ✅ desktop 使用 |
| Niri | Scrollable-tiling Wayland compositor | ✅ desktop 使用 |
| NixOS-WSL | NixOS 在 WSL2 上的集成 | ✅ wsl 使用 |
| rust-overlay | Rust 工具链管理 | ✅ |
| pkgs-by-name-for-flake-parts | 自定义包管理简化 | ⚠️ 已声明未启用 |

---

## Nix Architecture（项目特定架构）

### 核心架构模式

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

### Flake Inputs 管理

**关键约束**：所有 inputs **必须**在 `flake.nix` 中集中声明。这是 Nix flake 的设计限制 — inputs 是声明式的仓库源依赖，无法分散到模块中。

**模块如何访问 inputs**：
- flake-parts 模块最外层：`{inputs, ...}:` 参数（如 `rust.nix`）
- NixOS/HM 模块内部：通过 `specialArgs` 传递（已在 `host-machines.nix:19-24,36` 配置）
- topLevel 参数：`topLevel.inputs`（极少使用）

**当前 Inputs 清单**：

| Input | 用途 | 使用位置 |
|-------|------|---------|
| flake-parts | 模块框架 | `modules/flake-parts/flake-parts.nix` |
| nixpkgs | 包仓库 | 全局 |
| home-manager | 用户环境 | `modules/flake-parts/host-machines.nix` |
| import-tree | 目录扫描 | `flake.nix:74-75` |
| nixos-wsl | WSL 集成 | `hosts/nixos-wsl/` |
| niri | Wayland compositor | `modules/desktop/niri.nix` |
| rust-overlay | Rust 工具链 | `modules/dev/languages/rust.nix` |
| wired-notify | 通知守护进程 | `hosts/nixos-desktop/` |
| catppuccin | 主题 | `hosts/nixos-desktop/` |
| treefmt-nix | 格式化 | `modules/flake-parts/fmt.nix` |
| disko | 声明式磁盘分区 | `modules/base/disko.nix` |
| pkgs-by-name-for-flake-parts | 自定义包管理 | **未启用** |

### 目录与注册路径映射

| 目录位置 | 注册路径 | 用途 |
|---------|---------|------|
| `modules/dev/*.nix` | `homeManager.dev` | 开发工具（自动合并） |
| `modules/shell/*.nix` | `homeManager.shell` | Shell 工具（自动合并） |
| `modules/desktop/*.nix` | `homeManager.desktop` + 各自独立 `nixos.*` | 桌面环境（HM 聚合，NixOS 分散） |
| `modules/base/*.nix` | `nixos.base` + `homeManager.base` | 基础配置 |
| `modules/base/facter.nix` | `nixos.facter` | 硬件检测 |
| `modules/base/disko.nix` | `nixos.disko` | 声明式磁盘分区 |
| `modules/wsl/default.nix` | `nixos.wsl` + `homeManager.wsl` | WSL 统一配置 |
| `modules/users/loss/default.nix` | `nixos.loss` + `homeManager.loss` + `flake.meta.users` | 用户配置 |
| `modules/flake-parts/*.nix` | 系统生成器 | 架构核心 |

### Module Namespace Registry

**NixOS 命名空间**：

| 命名空间 | 注册源 | 说明 |
|----------|--------|------|
| `nixos.base` | `base/nix.nix`, `i18n.nix`, `time/`, `system/`, `console/` | 多文件自动合并 |
| `nixos.facter` | `base/facter.nix` | nixos-facter 工具 |
| `nixos.disko` | `base/disko.nix` | 声明式磁盘分区 |
| `nixos.rust` | `dev/languages/rust.nix` | Rust overlay 注入 |
| `nixos.wsl` | `wsl/default.nix` | WSL 系统配置 |
| `nixos.loss` | `users/loss/default.nix` | 用户系统配置 |
| `nixos.nvidia` | `desktop/nvidia.nix` | NVIDIA 驱动 |
| `nixos.niri` | `desktop/niri.nix` | Niri compositor |
| `nixos.audio` | `desktop/audio.nix` | PipeWire 音频 |
| `nixos.bluetooth` | `desktop/bluetooth.nix` | 蓝牙 |
| `nixos.power` | `desktop/power.nix` | 电源管理 |
| `nixos.fcitx5` | `desktop/fcitx5.nix` | 输入法 |
| `nixos.swaylock` | `desktop/swaylock.nix` | PAM 认证 |
| `nixos.fonts` | `desktop/fonts.nix` | 系统字体 |

**Home Manager 命名空间**：

| 命名空间 | 注册源 | 说明 |
|----------|--------|------|
| `homeManager.base` | `base/home.nix`, `base/nix.nix` | 多文件自动合并 |
| `homeManager.shell` | `shell/*.nix`（11 文件） | 多文件自动合并 |
| `homeManager.dev` | `dev/*.nix`（14 文件含 languages/） | 多文件自动合并 |
| `homeManager.desktop` | `desktop/*.nix`（14+ 文件） | 多文件自动合并 |
| `homeManager.wsl` | `wsl/default.nix` | WSL 用户配置 |
| `homeManager.loss` | `users/loss/default.nix` | 用户 HM 配置 |

### 主机配置示例

```nix
# hosts/nixos-wsl/default.nix（完整 NixOS 系统）
{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos."hosts/nixos-wsl" = {...}: {
    imports = with config.flake.modules.nixos;
      [
        inputs.nixos-wsl.nixosModules.default  # WSL 核心支持
        base    # NixOS 基础配置
        rust    # Rust 工具链
        wsl     # WSL 系统级配置
        loss    # 用户系统配置
      ]
      ++ [
        {
          home-manager.users.loss = {
            imports = with config.flake.modules.homeManager; [
              base shell dev
              wsl     # WSL 用户级配置
              loss    # 用户 Home Manager 配置
            ];
          };
        }
      ];
  };
}

# hosts/nixos-desktop/default.nix（桌面系统 + facter 硬件检测）
{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos."hosts/nixos-desktop" = {...}: {
    imports = with config.flake.modules.nixos;
      [
        {hardware.facter.reportPath = ./facter.json;}    # nixos-facter 硬件检测
        inputs.catppuccin.nixosModules.catppuccin         # 外部 NixOS 模块
        {nixpkgs.overlays = [inputs.wired-notify.overlays.default];}  # 外部 overlay

        base facter fonts nvidia niri
        audio bluetooth power fcitx5 swaylock
        loss
      ]
      ++ [
        {
          home-manager.users.loss = {
            imports = with config.flake.modules.homeManager; [
              inputs.catppuccin.homeModules.catppuccin      # 外部 HM 模块
              inputs.wired-notify.homeManagerModules.default
              base shell dev desktop loss
            ];
          };
        }
      ];

    # 硬件特定配置（磁盘、网络、启动）直接写在 host 中
    boot.loader.systemd-boot.enable = true;
    networking.hostName = "nixos-desktop";
    networking.networkmanager.enable = true;
  };
}

# hosts/fedora-wsl/default.nix（仅 Home Manager，Non-NixOS）
{config, ...}: {
  flake.modules.homeManager."hosts/fedora-wsl" = {...}: {
    imports = with config.flake.modules.homeManager; [
      base shell dev loss
      wsl     # 跨发行版复用
    ];

    home = {
      username = "loss";
      homeDirectory = "/home/loss";
    };

    targets.genericLinux.enable = true;
  };
}
```

### flake-parts 模块写法

```nix
# 情况1：简单配置（无 pkgs 引用）
{
  flake.modules.homeManager.dev = {
    programs.direnv.enable = true;
  };
}

# 情况2：需要 pkgs（必须用函数形式）
{
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home.packages = with pkgs; [ripgrep jq];
  };
}

# 情况3：同时注册多个目标（如 modules/wsl/default.nix）
{
  flake.modules = {
    nixos.wsl = _: { /* NixOS 级配置 */ };
    homeManager.wsl = {pkgs, ...}: { /* HM 级配置 */ };
  };
}

# 情况4：需要 flake inputs + Overlay 注入（如 modules/dev/languages/rust.nix）
{inputs, ...}: {
  flake.modules = {
    nixos.rust = {
      nixpkgs.overlays = [inputs.rust-overlay.overlays.default];
    };
    homeManager.dev = {pkgs, ...}: {
      nixpkgs.overlays = [inputs.rust-overlay.overlays.default];  # HM 层也注入，支持 Non-NixOS
      home.packages = [pkgs.rust-bin.stable.latest.default];
    };
  };
}

# 情况5：topLevel 参数访问 flake 元数据（如 modules/users/loss/default.nix）
topLevel: {
  flake = {
    meta.users.loss = { name = "Loss"; username = "loss"; email = "..."; };
    modules.nixos.loss = _: {
      users.users.loss = {
        description = topLevel.config.flake.meta.users.loss.name;
        # ...
      };
    };
    modules.homeManager.loss = { home.username = "loss"; };
  };
}

# 情况6：在 host 中注入外部 overlay（如 hosts/nixos-desktop/default.nix）
# 当外部 input 提供 overlay 且仅特定 host 需要时：
{nixpkgs.overlays = [inputs.wired-notify.overlays.default];}
```

### WSL 统一模块架构

`modules/wsl/default.nix` 同时注册两个目标：

1. **`nixos.wsl`** - 系统级配置（仅 NixOS-WSL 使用）
   - WSL 核心（docker-desktop, 自动挂载）
   - 禁用 bootloader, systemd-networkd
   - NixOS 兼容性（nix-ld）
   - 系统环境变量

2. **`homeManager.wsl`** - 用户级配置（跨发行版通用）
   - Windows 路径集成
   - WSL 工具和启动器
   - Shell 别名（explorer, notepad, clip）
   - PATH 注入

### Desktop 模块架构

`modules/desktop/*.nix` 采用 **HM 侧聚合 + NixOS 侧分散** 模式：

**HM 侧**：所有 desktop/*.nix 的 HM 配置合并到 `homeManager.desktop`，host 只需导入一次 `desktop`：
- alacritty, browser, fuzzel, media, niri, screenshot, swayidle, swaylock, swww, theming, waybar, wired-notify, wlogout, fcitx5

**NixOS 侧**：各模块注册到独立命名空间，host 需逐一导入：
- `nixos.nvidia`, `nixos.audio`, `nixos.bluetooth`, `nixos.power`, `nixos.fcitx5`, `nixos.swaylock`, `nixos.niri`, `nixos.fonts`

**外部依赖**（需在 host imports 中直接导入）：
- `inputs.catppuccin.nixosModules.catppuccin` + `inputs.catppuccin.homeModules.catppuccin`
- `inputs.wired-notify.overlays.default`（overlay）+ `inputs.wired-notify.homeManagerModules.default`

### 硬件检测 (nixos-facter)

替代传统 `hardware-configuration.nix`：
- `modules/base/facter.nix`：注册 `nixos.facter` 模块，安装 facter CLI
- `hosts/nixos-desktop/facter.json`：硬件检测报告
- host 中引用：`{hardware.facter.reportPath = ./facter.json;}`
- 生成命令：`sudo nix run nixpkgs#nixos-facter -- -o hosts/<hostname>/facter.json`
- **仅 desktop/VM host 使用**，WSL 不需要（硬件由 Windows 管理）

---

## Modern Toolchain（现代工具链）

| 传统命令 | 现代替代 | 配置位置 |
|---------|---------|---------|
| `find` | `fd` | `modules/shell/fd.nix` |
| `grep` | `rg` (ripgrep) | `modules/dev/ripgrep.nix` |
| `ls` | `eza` | `modules/shell/eza.nix` |
| `cat` | `bat` | `modules/shell/bat.nix` |
| `cd` | `z` (zoxide) | `modules/shell/zoxide.nix` |
| `tree` | `eza --tree` | `modules/shell/eza.nix` |

### 使用示例
```bash
fd --extension nix        # 查找 .nix 文件
rg "flake.modules"         # 搜索文本
eza --tree --level=3       # 目录树
```

---

## Common Tasks（常见任务）

### 添加开发工具

```nix
# 创建 modules/dev/<tool>.nix（仅此一步）

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

### 添加系统服务

```nix
# 创建 modules/<category>/<name>.nix
{
  flake.modules.nixos.<module-name> = {
    services.<service>.enable = true;
  };
}
# 然后在 hosts/*/default.nix 中手动导入
```

### 添加新主机

```nix
# 1. 创建 hosts/<hostname>/default.nix
# 2. 选择注册模式：
#    - 完整 NixOS: flake.modules.nixos."hosts/<hostname>" = {...}: { ... };
#    - 仅 HM:     flake.modules.homeManager."hosts/<hostname>" = {...}: { ... };
# 3. 导入所需模块（参考现有 host）
# 4. 如需硬件检测：sudo nix run nixpkgs#nixos-facter -- -o hosts/<hostname>/facter.json
# 5. host-machines.nix 自动检测 "hosts/" 前缀并注册到 nixosConfigurations/homeConfigurations
```

### 部署命令

```bash
sudo nixos-rebuild switch --flake .#nixos-wsl         # 部署 WSL
sudo nixos-rebuild switch --flake .#nixos-desktop      # 部署桌面
sudo nixos-rebuild switch --flake .#nixos-vm           # 部署 VM
home-manager switch --flake .#hosts/fedora-wsl         # 部署独立 HM
./scripts/deploy.sh --local nixos-desktop               # 本机 Live USB 安装 (disko)
./scripts/deploy.sh nixos-vm 192.168.122.100            # 远程部署 (nixos-anywhere)
nix fmt                                                 # 格式化
nix flake check                                         # 语法检查
```

### 调试配置

```bash
nix eval .#nixosConfigurations.nixos-wsl      # 评估配置
nix eval .#nixosConfigurations.nixos-desktop   # 评估桌面配置
nix repl                                      # 交互式检查
:lf .
:p outputs.nixosConfigurations.nixos-wsl.config.services
```

---

## File Permissions（文件修改权限）

### 自由修改
- `modules/*`（添加/编辑）
- `scripts/*`
- `CLAUDE.md`, `README.md`, `AGENTS.md`

### 需要确认
- `flake.nix` 或 `flake.lock`
- `hosts/*`
- `modules/flake-parts/*`

### 禁止修改
- Git 历史

---

## Network Proxy（网络代理）

Claude Code Bash 环境非交互式，必须使用代理包装器：

```bash
# 正确方式
/home/loss/nix-config/scripts/proxy-wrapper.sh git push

# 或直接设置环境变量
HOST=$(ip route | awk '/default/ {print $3; exit}') && \
  http_proxy="http://${HOST}:7890" \
  https_proxy="http://${HOST}:7890" \
  curl https://example.com
```

---

## Resources（参考资源）

- NixOS Options: https://search.nixos.org/options
- Nix Packages: https://search.nixos.org/packages
- Home Manager Options: https://nix-community.github.io/home-manager/options.xhtml
- Flake-parts: https://flake.parts/
- import-tree: https://github.com/vic/import-tree
- nixos-facter: https://github.com/numtide/nixos-facter
- disko: https://github.com/nix-community/disko
- nixos-anywhere: https://github.com/nix-community/nixos-anywhere
- Niri Flake: https://github.com/sodiboo/niri-flake
- Catppuccin/nix: https://github.com/catppuccin/nix
- Architecture reference: https://github.com/drupol/infra

---

## Success Criteria（成功标准）

1. `nix flake check` 通过
2. 代码遵循项目架构
3. 提交消息使用 `/zcf:git-commit` 生成
4. 用户可理解变更内容

---

**记住**：稳定性和可维护性比炫技更重要。简单、清晰、可预测的代码是最好的代码。
