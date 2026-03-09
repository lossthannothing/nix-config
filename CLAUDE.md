# CLAUDE.md

为 Claude AI 助手提供的项目上下文。

---

## 角色

NixOS DevOps 工程师，精通 flake-parts 架构和模块系统设计。

---

## 核心架构原则

### 三层架构

```
┌─────────────────────────────────────────────────────────┐
│  flake.nix (机制层)                                    │
│  - inputs 集中声明                                     │
│  - import-tree 自动扫描                                │
│  - ./modules/* → flake.modules.*                      │
│  - ./hosts/*   → nixosConfigurations                  │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  modules/ (能力层)                                      │
│  - flake.modules.nixos.*      (系统级配置)              │
│  - flake.modules.homeManager.* (用户级配置)           │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  hosts/ (实例层)                                        │
│  - 通过 imports 组装 modules 中的能力                   │
│  - host-machines.nix 自动生成配置                     │
└─────────────────────────────────────────────────────────┘
```

### 关键设计决策

| 决策 | 说明 |
|------|------|
| `useGlobalPkgs = false` | 解绑 HM/NixOS pkgs，允许模块独立注入 overlay |
| `useUserPackages = true` | 用户包安装到系统 profile |
| `specialArgs` | 传递 `inputs` 和 `hostConfig` 到所有子模块 |
| 自动注入 `genericLinux` | 非 NixOS 独立 HM 主机自动启用兼容层 |

---

## 模块命名空间

### NixOS 命名空间 (需在 host 中显式导入)

| 命名空间 | 源文件 | 说明 |
|----------|--------|------|
| `nixos.base` | `base/*.nix` | 多文件自动合并 |
| `nixos.facter` | `base/facter.nix` | 硬件检测 |
| `nixos.disko` | `base/disko.nix` | 声明式磁盘分区 |
| `nixos.rust` | `dev/languages/rust.nix` | Rust overlay 注入 |
| `nixos.wsl` | `wsl/default.nix` | WSL 系统配置 |
| `nixos.loss` | `users/loss/default.nix` | 用户系统配置 |
| `nixos.nvidia` | `desktop/nvidia.nix` | NVIDIA 驱动 |
| `nixos.niri` | `desktop/niri.nix` | Wayland compositor |
| `nixos.audio` | `desktop/audio.nix` | PipeWire 音频 |
| `nixos.bluetooth` | `desktop/bluetooth.nix` | 蓝牙支持 |
| `nixos.power` | `desktop/power.nix` | 电源管理 |
| `nixos.fcitx5` | `desktop/fcitx5.nix` | 输入法 (NixOS+HM) |
| `nixos.swaylock` | `desktop/swaylock.nix` | PAM 认证 |
| `nixos.fonts` | `desktop/fonts.nix` | 系统字体 |

### Home Manager 命名空间 (自动合并)

| 命名空间 | 源文件 | 说明 |
|----------|--------|------|
| `homeManager.base` | `base/home.nix`, `base/nix.nix` | 多文件自动合并 |
| `homeManager.shell` | `shell/*.nix` (11 文件) | 自动合并 |
| `homeManager.dev` | `dev/*.nix` (14 文件) | 自动合并 |
| `homeManager.desktop` | `desktop/*.nix` (14+ 文件) | 自动合并 |
| `homeManager.wsl` | `wsl/default.nix` | WSL 用户配置 |
| `homeManager.loss` | `users/loss/default.nix` | 用户 HM 配置 |

### 外部依赖 (需在 host imports 中显式导入)

```nix
# catppuccin 主题
inputs.catppuccin.nixosModules.catppuccin
inputs.catppuccin.homeModules.catppuccin

# wired-notify 通知守护进程
{ nixpkgs.overlays = [inputs.wired-notify.overlays.default]; }
inputs.wired-notify.homeManagerModules.default
```

---

## 常用命令

### 验证与格式化

```bash
# 验证 flake 配置 (修改后必须运行)
nix flake check

# 格式化代码 (alejandra, deadnix, statix 等)
nix fmt

# 查看可用系统
nix flake show
```

### 部署

```bash
# 交互式部署菜单 (推荐)
./scripts/deploy.sh

# NixOS 系统重建
sudo nixos-rebuild switch --flake .#nixos-wsl
sudo nixos-rebuild switch --flake .#nixos-desktop
sudo nixos-rebuild switch --flake .#nixos-vm

# Home Manager 独立部署
home-manager switch --flake .#hosts/fedora-wsl

# Live USB 安装 (disko 声明式分区)
./scripts/deploy.sh --local nixos-desktop

# 远程部署 (nixos-anywhere)
./scripts/deploy.sh nixos-vm 192.168.122.100
```

### 开发与调试

```bash
# 更新依赖
nix flake update

# 构建但不激活
nixos-rebuild build --flake .#nixos-wsl

# 配置差异检查
nixos-rebuild dry-run --flake .#nixos-wsl

# 交互式 REPL
nix repl
:lf .
:p outputs.nixosConfigurations.nixos-wsl.config.services
```

---

## 网络代理

Bash 环境非交互式，必须使用代理包装器：

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

## 文件修改权限

### 自由修改
- `modules/*`（添加/编辑）
- `scripts/*`
- `CLAUDE.md`, `README.md`

### 需要确认
- `flake.nix` 或 `flake.lock`
- `hosts/*`
- `modules/flake-parts/*`

---

## 响应语言

使用简体中文响应。

---

## 参考仓库 (.ref/)

本项目使用 `.ref/` 目录管理外部参考仓库，用于学习对比。

- **本地可用**：AI 助手可直接读取本地文件，无需远程请求
- **不提交 Git**：`.ref/` 已加入 `.gitignore`，不会被推送至 GitHub

### 当前参考

| 仓库 | 标签 | 用途 |
|------|------|------|
| [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config) | `v2.0` | 传统手动导入架构参考，与本项目 flake-parts 形成对比 |

### 快速开始

```bash
# 首次设置 - 克隆所有参考仓库
./.ref/init.sh

# 检查参考仓库是否存在
./.ref/check.sh

# 查看使用指南
cat .ref/README.md
```

### 启动时自动检查

Claude Code 启动时会自动检查 `.ref/` 中的参考仓库是否存在：
- 如果不存在，提示运行 `./.ref/init.sh`
- 使用方式：**阅读参考而非复制代码**

### 关键区别

| 本项目 (flake-parts) | ryan4yin (传统方式) |
|---------------------|---------------------|
| `import-tree` 自动扫描 | 手动列出所有导入路径 |
| 命名空间 `flake.modules.*` | 相对路径 `../../modules/...` |
| 三层架构 (机制/能力/实例) | 扁平结构，主机直接导入模块 |

**使用参考时**：理解其配置意图，转化为本项目的架构方式，而非直接复制文件。

### 与 AI 助手配合使用

当要求 AI 助手（如 Claude）参考外部配置时：

1. **先检查参考是否存在**：
   ```bash
   ./.ref/check.sh || ./.ref/init.sh
   ```

2. **告诉 AI 阅读参考**：
   > "请阅读 `.ref/ryan4yin-nix-config/modules/home/niri/` 的配置，了解他的 niri 设置思路，然后基于我们项目的架构给出建议。"

3. **明确约束**：
   - "不要直接复制文件"
   - "转化为我们的 flake-parts 架构"
   - "使用我们的命名空间风格"

---

## 子文档索引

| 文档路径 | 内容 |
|---------|------|
| `modules/flake-parts/CLAUDE.md` | flake-parts 系统生成器层架构、host-machines.nix 工作原理 |
| `AGENTS.md` | AI 助手项目上下文、代码风格、Git 工作流、常见任务 |
