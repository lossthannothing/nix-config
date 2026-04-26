# nix-config

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md) [![简体中文](https://img.shields.io/badge/lang-简体中文-red.svg)](README_CN.md)

基于 [vic/den](https://github.com/vic/den) 构建的个人 NixOS 配置——一个上下文感知、面向切面 (aspect-driven) 的声明式 Nix 系统框架。

## 架构

```
flake.nix (入口)
  └── flake-parts + import-tree
       └── modules/* (自动扫描)
            ├── den.nix          → 框架初始化 + "loss" 命名空间
            ├── default.nix      → den.default (所有主机/用户的全局基线)
            ├── loss.nix         → den.aspects.loss (用户 "loss")
            ├── nixpkgs.nix      → perSystem pkgs + overlays
            ├── formatter.nix    → treefmt-nix
            ├── system/          → loss.system (nix, locale, wsl)
            ├── shell/           → loss.shell (zsh, starship, bat, ...)
            ├── editors/         → loss.editors (neovim)
            ├── dev/             → loss.dev.* (go, rust, python, js, nix, tools)
            ├── profiles/        → loss.profiles.* (wsl 偏好)
            └── hosts/           → den.hosts + 主机特定 aspects
                 └── nixos-wsl/  → WSL2 NixOS 实例
```

### 工作原理

Den 用**切面 (aspects)** 替代扁平模块列表——可组合的、上下文感知的配置包。一个 aspect 如 `loss.shell._.zsh` 能感知自己是在配置 NixOS 主机、Home Manager 用户，还是两者兼有。

| 概念 | 示例 | 用途 |
|------|------|------|
| `den.default` | `modules/default.nix` | 所有主机/用户的基线配置 |
| `den.aspects.<name>` | `den.aspects.loss`, `den.aspects.nixos-wsl` | 命名配置包 |
| `den.hosts.<arch>.<host>` | `den.hosts.x86_64-linux.nixos-wsl` | 主机声明 |
| `loss.*` | `loss.shell`, `loss.dev._.rust` | 项目自定义命名空间 |
| `<loss/shell>` | 尖括号导入 | 可复用的切面引用 |

### 聚合模式

子切面通过 `includes` 聚合成组合切面：

```nix
# modules/shell/default.nix
loss.shell = {
  includes = with loss; [
    shell._.zsh
    shell._.starship
    shell._.git
    # ... 更多子切面
  ];
};
```

主机组合这些聚合：

```nix
# modules/hosts/nixos-wsl/default.nix
den.aspects.nixos-wsl = {
  includes = with loss; [
    system._.wsl
    profiles.wsl
    shell            # 聚合切面
    dev._.tools
    dev._.rust
    # ...
  ];
};
```

## 快速开始

### 前置要求

- Nix 2.19+，启用 flakes
- Git

### 部署

```bash
# 构建但不激活
nixos-rebuild build --flake .#nixos-wsl

# 部署
sudo nixos-rebuild switch --flake .#nixos-wsl

# 交互式部署菜单
./scripts/deploy.sh
```

### 常用命令

```bash
nix fmt                                        # 格式化 (alejandra + deadnix + statix)
nix flake check                                # 验证配置
nix flake update                               # 更新 inputs
nixos-rebuild dry-run --flake .#nixos-wsl      # 测试不应用
```

## 目录结构

```
nix-config/
├── flake.nix              # Flake 入口 — inputs + import-tree
├── flake.lock
├── CLAUDE.md              # AI 助手上下文
├── modules/               # 所有配置（import-tree 自动扫描）
│   ├── den.nix            #   Den 初始化 + "loss" 命名空间注册
│   ├── default.nix        #   den.default — 全局基线
│   ├── loss.nix           #   den.aspects.loss — 用户 "loss"
│   ├── nixpkgs.nix        #   perSystem pkgs, overlays, pkgs-by-name
│   ├── formatter.nix      #   treefmt-nix 多语言格式化
│   ├── system/            #   loss.system — nix 守护进程, 区域设置, wsl
│   ├── shell/             #   loss.shell — zsh, starship, git, bat, eza, ...
│   ├── editors/           #   loss.editors — neovim
│   ├── dev/               #   loss.dev.* — go, rust, python, js, nix, tools
│   ├── profiles/          #   loss.profiles.* — 平台特定偏好
│   └── hosts/             #   主机定义 + 每主机 aspects
│       └── nixos-wsl/     #     WSL2 NixOS
├── pkgs/by-name/          #   自定义包（pkgs-by-name-for-flake-parts）
├── scripts/               #   工具脚本
│   ├── deploy.sh              # 交互式部署 + disko + nixos-anywhere
│   ├── git-proxy.sh           # Git 代理包装器
│   ├── nixdaemon-proxy.sh     # Nix daemon 代理（物理机/VM）
│   ├── nix-daemon-wsl-proxy.sh # Nix daemon 代理（WSL）
│   └── shell-proxy.sh         # Shell 会话代理
└── .ref/                  #   参考仓库（gitignored）
```

## 配置指南

### 添加 Shell 工具

创建 `modules/shell/<tool>.nix`：

```nix
{ loss.shell._.<tool>.homeManager = { pkgs, ... }: {
  programs.<tool>.enable = true;
}; }
```

然后在 `modules/shell/default.nix` 的聚合中加入。

### 添加开发工具链

创建 `modules/dev/<lang>.nix`：

```nix
{ loss.dev._.<lang>.homeManager = { pkgs, ... }: {
  home.packages = [ pkgs.<lang> ];
}; }
```

然后在主机的 `den.aspects.<host>.includes` 中引入。

### 添加新主机

1. 创建 `modules/hosts/<hostname>/default.nix`
2. 声明主机并定义切面：

```nix
{ loss, ... }: {
  den.hosts.x86_64-linux.<hostname> = {};
  den.aspects.<hostname> = {
    includes = with loss; [
      system._.nix
      shell
      dev._.tools
    ];
    nixos = { ... }: {
      # 主机特定的 NixOS 配置
    };
  };
}
```

3. 部署：`sudo nixos-rebuild switch --flake .#<hostname>`

### 上下文感知切面

切面可以检查上下文（`host`、`user`、`home`）来生成不同配置：

```nix
{ den, ... }: {
  den.aspects.video = den.lib.take.exactly ({ host, user }: {
    nixos.users.users.${user.userName}.extraGroups = [ "video" ];
  });
}
```

需要不可用上下文参数的函数会被静默排除——无需条件判断样板代码。

## 技术栈

| 技术 | 角色 |
|------|------|
| [den](https://github.com/vic/den) | 上下文感知切面框架 |
| [flake-parts](https://flake.parts/) | 模块化 flake 组合 |
| [import-tree](https://github.com/vic/import-tree) | 自动扫描 `modules/` |
| [flake-aspects](https://github.com/vic/flake-aspects) | 切面基础设施 |
| [Home Manager](https://github.com/nix-community/home-manager) | 用户级配置管理 |
| [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) | NixOS on WSL2 |
| [treefmt-nix](https://github.com/numtide/treefmt-nix) | 多语言格式化 |
| [rust-overlay](https://github.com/oxalica/rust-overlay) | Rust 工具链 |
| [pkgs-by-name](https://github.com/nix-community/pkgs-by-name-for-flake-parts) | 自定义包自动发现 |

## 平台支持

| 主机 | 类型 | 描述 |
|------|------|------|
| nixos-wsl | NixOS | WSL2 开发环境 |

## 代理脚本 (WSL)

```bash
./scripts/git-proxy.sh git push              # Git 走代理
sudo ./scripts/nix-daemon-wsl-proxy.sh http  # Nix daemon 代理 (WSL)
sudo ./scripts/nixdaemon-proxy.sh http       # Nix daemon 代理（物理机/VM）
```

## 灵感来源

- **[vic/den](https://github.com/vic/den)** — 上下文感知的 Dendritic Nix 配置
- **[The Dendritic Pattern](https://github.com/vic/dendritic)** — Nixpkgs 模块系统模式
- **[drupol/infra](https://github.com/drupol/infra)** — 去中心化模块架构

## 许可证

MIT
