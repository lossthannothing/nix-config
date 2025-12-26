# Nix Config 重构规划（最终版）

## 当前架构分析

### 现状
```
nix-config/
├── flake.nix                    # 中心化配置，手动定义所有 nixosConfigurations
├── lib/
│   ├── default.nix              # 辅助函数库（包含 scanPaths）
│   ├── nixosSystem.nix          # 自定义系统构建函数
│   └── vars.nix                 # 全局变量（username）
├── hosts/
│   ├── wsl/                     # WSL 主机配置
│   └── nixos-vm/                # VM 主机配置
├── os/                          # NixOS 系统层配置
│   ├── base.nix
│   ├── system-pkgs.nix
│   └── features/                # 功能模块
└── home/                        # Home Manager 用户层配置
    ├── home.nix
    ├── shell/
    │   ├── default.nix          # 使用 scanPaths 自动导入
    │   ├── cli-tools.nix
    │   └── zsh.nix
    └── dev/
        ├── default.nix          # 使用 scanPaths 自动导入
        └── ...
```

### 问题点
1. **中心化配置**: flake.nix 必须手动定义所有 nixosConfigurations
2. **配置分离**: os/ 和 home/ 分开，相关功能配置分散
3. **手动组装**: 每个主机需要手动列出所有模块路径
4. **粗粒度模块**: shell/cli-tools.nix 包含多个工具，难以单独控制
5. **扩展性差**: 添加新主机需要修改 flake.nix

---

## 目标架构（基于 drupol/infra 模式）

### 核心理念
1. **去中心化**: flake.nix 只提供机制，不知道具体主机
2. **分布式注册**: 每台主机自己注册到 `flake.modules.nixos."hosts/xxx"`
3. **同位配置**: NixOS 和 Home Manager 配置在同一处声明
4. **细粒度模块**: 每个工具/功能独立文件
5. **自动发现**: 使用 import-tree 自动扫描并加载模块
6. **声明式控制**: 通过文件存在来控制功能，而非条件逻辑

### 新目录结构
```
nix-config/
├── flake.nix                           # 极简入口，只定义机制
├── modules/
│   ├── flake-parts/
│   │   └── host-machines.nix           # 🔑 自动生成 nixosConfigurations
│   ├── users/
│   │   └── loss.nix                    # 用户定义也是模块
│   ├── base/
│   │   └── default.nix                 # nixos.base + homeManager.base
│   ├── dev/
│   │   ├── git.nix                     # homeManager.dev (单个工具)
│   │   ├── vscode.nix                  # homeManager.dev
│   │   └── direnv.nix                  # homeManager.dev
│   ├── shell/                          # 细粒度拆分
│   │   ├── bat.nix                     # homeManager.shell
│   │   ├── fzf.nix                     # homeManager.shell
│   │   ├── lsd.nix                     # homeManager.shell
│   │   ├── fd.nix                      # homeManager.shell
│   │   ├── zsh.nix                     # homeManager.shell
│   │   ├── zoxide.nix                  # homeManager.shell
│   │   └── ...                         # 每个工具独立文件
│   └── desktop/
│       └── default.nix                 # nixos.desktop + homeManager.desktop
└── hosts/
    ├── wsl/
    │   └── default.nix                 # 自注册 + WSL 特定配置
    └── nixos-vm/
        ├── default.nix                 # 自注册 + VM 特定配置
        └── hardware-configuration.nix  # (预留) nixos-facter 生成的硬件配置
```

---

## 重构步骤

### 阶段 1: 准备基础架构

#### 1.1 添加 import-tree 依赖

```nix
# flake.nix inputs
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = { ... };
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    dotfiles = { ... };

    # 新增
    import-tree.url = "github:vic/import-tree";
  };
}
```

#### 1.2 创建 host-machines.nix 生成器

```nix
# modules/flake-parts/host-machines.nix
{ inputs, ... }:
{
  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs) lib;

      # 从 flake.modules.nixos 中提取所有 "hosts/xxx" 模块
      hostModules = lib.filterAttrs
        (name: _: lib.hasPrefix "hosts/" name)
        config.flake.modules.nixos;

      # 为每个主机生成 nixosConfiguration
      mkHost = name: module:
        let
          # 从 "hosts/nixos-wsl" 提取 "nixos-wsl"
          hostName = lib.removePrefix "hosts/" name;
        in
        lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = {
            inherit inputs;
            inherit (inputs) dotfiles;
          };

          modules = [
            # Home Manager 集成
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit (inputs) dotfiles;
                };
              };
            }

            # 主机模块
            module
          ];
        };
    in
    lib.mapAttrs mkHost hostModules;
}
```

#### 1.3 重写 flake.nix

```nix
# flake.nix
{
  description = "A personal Nix configuration for NixOS and Home Manager.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    dotfiles = {
      url = "github:lossthannothing/.dotfiles/master";
      flake = false;
    };
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        # 启用 flake-parts 模块系统
        flake-parts.flakeModules.modules

        # 自动导入所有模块
        (import-tree.lib.flattenTree ./modules)
        (import-tree.lib.flattenTree ./hosts)
      ];
    };
}
```

---

### 阶段 2: 迁移配置模块

#### 2.1 创建用户模块

```nix
# modules/users/loss.nix
{
  flake.modules.nixos.loss = { pkgs, ... }: {
    users.users.loss = {
      isNormalUser = true;
      description = "Loss";
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
    };
  };
}
```

#### 2.2 创建基础模块

```nix
# modules/base/default.nix
{ pkgs, ... }:
{
  flake.modules = {
    # NixOS 层基础配置
    nixos.base = { pkgs, ... }: {
      # 从 os/base.nix 迁移
      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };

      environment.systemPackages = with pkgs; [
        vim
        wget
        curl
        git
      ];

      # 从 os/system-pkgs.nix 合并
      nixpkgs.config.allowUnfree = true;
    };

    # Home Manager 层基础配置
    homeManager.base = { config, ... }: {
      # 从 home/home.nix 迁移
      home.username = "loss";
      home.homeDirectory = "/home/loss";
      home.stateVersion = "24.05";

      programs.home-manager.enable = true;

      xdg.enable = true;
    };
  };
}
```

#### 2.3 创建细粒度 shell 模块

**每个工具独立文件，直接声明式配置：**

```nix
# modules/shell/bat.nix
{ pkgs, ... }:
{
  flake.modules.homeManager.shell = {
    programs.bat = {
      enable = true;
      config.theme = "TwoDark";
    };
  };
}

# modules/shell/lsd.nix
{ pkgs, ... }:
{
  flake.modules.homeManager.shell = {
    home.packages = [ pkgs.lsd ];
  };
}

# modules/shell/fd.nix
{ pkgs, ... }:
{
  flake.modules.homeManager.shell = {
    home.packages = [ pkgs.fd ];
  };
}

# modules/shell/fzf.nix
{ pkgs, ... }:
{
  flake.modules.homeManager.shell = {
    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
      ];
    };
  };
}

# modules/shell/zoxide.nix
{ pkgs, ... }:
{
  flake.modules.homeManager.shell = {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}

# modules/shell/zsh.nix
{ pkgs, dotfiles, lib, ... }:
{
  flake.modules.homeManager.shell = {
    programs.zsh = {
      enable = true;

      envExtra = ''
        PRIVATE_ENV_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/private/env"
        if [ -r "$PRIVATE_ENV_CONFIG" ] && [ -f "$PRIVATE_ENV_CONFIG" ]; then
          set -a
          source "$PRIVATE_ENV_CONFIG"
          set +a
        fi
        export PATH="$HOME/.local/bin:$PATH"
      '';

      shellAliases = {
        ls = "lsd";
        ll = "lsd -alhF";
        la = "lsd -A";
        cat = "bat";
        grep = "grep --color=auto";
        zi = "z -i";
        ".." = "cd ..";
        "..." = "cd ../..";
      };

      initContent = let
        p10kInit = lib.mkOrder 500 ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
          [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
        '';

        toolsInit = lib.mkOrder 1000 ''
          if command -v sheldon &> /dev/null; then
            eval "$(sheldon source)"
          fi
          if command -v fnm &> /dev/null; then
            eval "$(fnm env)"
          fi
        '';

        functionsInit = lib.mkOrder 1000 ''
          source "${dotfiles}/zsh/.zsh/functions.zsh"
        '';
      in
        lib.mkMerge [ p10kInit toolsInit functionsInit ];
    };

    home.file.".p10k.zsh".source = "${dotfiles}/zsh/.p10k.zsh";
  };
}

# modules/shell/sheldon.nix
{ pkgs, dotfiles, ... }:
{
  flake.modules.homeManager.shell = {
    home.packages = [ pkgs.sheldon ];
    home.file.".config/sheldon/plugins.toml".source =
      "${dotfiles}/config/.config/sheldon/plugins.toml";
  };
}
```

**不需要 default.nix 或者只放通用配置：**

```nix
# modules/shell/default.nix（可选）
{ lib, ... }:
{
  flake.modules.homeManager.shell = {
    # 只放不属于任何具体工具的通用配置
    home.sessionVariables = {
      EDITOR = lib.mkDefault "vim";
    };
  };
}
```

#### 2.4 创建 dev 模块

```nix
# modules/dev/git.nix
{ pkgs, ... }:
{
  flake.modules.homeManager.dev = {
    programs.git = {
      enable = true;
      userName = "loss";
      userEmail = "your-email@example.com";
    };
  };
}

# modules/dev/gh.nix
{ pkgs, ... }:
{
  flake.modules.homeManager.dev = {
    programs.gh = {
      enable = true;
      extensions = [ pkgs.gh-copilot ];
    };

    nixpkgs.config.allowUnfree = true;
  };
}

# modules/dev/vscode.nix
{ pkgs, ... }:
{
  flake.modules.homeManager.dev = {
    programs.vscode = {
      enable = true;
      # ... 配置
    };
  };
}
```

#### 2.5 模块迁移对应表

| 旧路径 | 新路径 | 说明 |
|--------|--------|------|
| `lib/vars.nix` | **删除** | username 直接在 hosts 中硬编码 |
| `lib/nixosSystem.nix` | `modules/flake-parts/host-machines.nix` | 自动生成器 |
| `lib/default.nix` | **删除** | scanPaths 被 import-tree 替代 |
| `os/base.nix` | `modules/base/default.nix` (nixos.base) | 系统基础 |
| `os/system-pkgs.nix` | `modules/base/default.nix` (nixos.base) | 合并到基础 |
| `home/home.nix` | `modules/base/default.nix` (homeManager.base) | 用户基础 |
| `home/shell/cli-tools.nix` | `modules/shell/{lsd,fd,...}.nix` | 拆分为独立文件 |
| `home/shell/zsh.nix` | `modules/shell/zsh.nix` | 保持独立 |
| `home/shell/default.nix` | **删除或最小化** | 不再需要 scanPaths |
| `home/dev/*.nix` | `modules/dev/*.nix` | 每个工具独立 |

---

### 阶段 3: 重写主机配置

#### 3.1 重写 hosts/wsl/default.nix

**关键变化**：
1. 不使用 `loadNixosAndHmModuleForUser` 函数
2. 直接使用 `with config.flake.modules.{nixos|homeManager}` 引用模块
3. Home Manager 配置直接内联

```nix
# hosts/wsl/default.nix
{ config, inputs, ... }:
{
  # 自注册到 flake.modules.nixos
  flake.modules.nixos."hosts/nixos-wsl" = {
    imports =
      with config.flake.modules.nixos;
      [
        # 1. 平台基底
        inputs.nixos-wsl.nixosModules.default

        # 2. NixOS 模块
        base

        # 3. 用户
        loss
      ]
      # 4. Home Manager 配置（直接内联）
      ++ [
        {
          home-manager.users.loss = {
            imports = with config.flake.modules.homeManager; [
              base
              shell   # 自动包含所有 shell/*.nix 的配置
              dev     # 自动包含所有 dev/*.nix 的配置
            ];
          };
        }
      ];

    # WSL 特定配置
    wsl = {
      enable = true;
      defaultUser = "loss";
    };

    system.stateVersion = "24.05";
  };
}
```

#### 3.2 重写 hosts/nixos-vm/default.nix（示例）

```nix
# hosts/nixos-vm/default.nix
{ config, inputs, ... }:
{
  flake.modules.nixos."hosts/nixos-vm" = {
    imports =
      with config.flake.modules.nixos;
      [
        # 硬件配置（nixos-facter 生成）
        ./hardware-configuration.nix

        # 功能模块
        base
        desktop

        # 用户
        loss
      ]
      ++ [
        {
          home-manager.users.loss = {
            imports = with config.flake.modules.homeManager; [
              base
              shell
              dev
              desktop
            ];
          };
        }
      ];

    system.stateVersion = "24.05";
  };
}
```

---

### 阶段 4: 清理工作

#### 4.1 删除旧文件/目录

```bash
rm -rf lib/
rm -rf os/
rm -rf home/
```

#### 4.2 文件清单

**保留**：
- `flake.nix`（重写后的极简版本）
- `hosts/`（重写后的主机配置）
- `.gitmodules`、`.gitignore`（Git 配置）
- `scripts/`（辅助脚本）

**新增**：
- `modules/flake-parts/`（架构核心）
- `modules/users/`（用户定义）
- `modules/base/`（基础模块）
- `modules/shell/`（Shell 工具，细粒度拆分）
- `modules/dev/`（开发工具，细粒度拆分）
- `modules/desktop/`（桌面环境，如果需要）

**删除**：
- `lib/`（完全删除）
- `os/`（迁移到 modules/）
- `home/`（迁移到 modules/）

---

## 核心概念总结

### 1. 模块自动合并

所有定义 `flake.modules.homeManager.shell` 的文件会被 Nix 自动合并：

```nix
# modules/shell/bat.nix
flake.modules.homeManager.shell = { programs.bat.enable = true; };

# modules/shell/lsd.nix
flake.modules.homeManager.shell = { home.packages = [ pkgs.lsd ]; };

# 最终合并结果
flake.modules.homeManager.shell = {
  programs.bat.enable = true;
  home.packages = [ pkgs.lsd ];
};
```

### 2. 文件即功能

- **想要 bat** → 保留 `modules/shell/bat.nix`
- **不想要 bat** → 删除 `modules/shell/bat.nix`
- **临时禁用 bat** → 在 hosts 中覆盖：`programs.bat.enable = lib.mkForce false;`

### 3. 不需要 default.nix 控制默认值

每个子模块直接声明配置，不需要通过 options/features 来控制：

```nix
# ❌ 过度设计
options.features.bat = lib.mkEnableOption "bat" // { default = true; };
config = lib.mkIf config.features.bat { ... };

# ✅ 简洁直接
programs.bat = {
  enable = true;
  config.theme = "TwoDark";
};
```

### 4. nixos-facter 预留方式

```nix
# hosts/physical-machine/default.nix
flake.modules.nixos."hosts/physical-machine" = {
  imports = [
    ./hardware-configuration.nix  # facter 生成
    # ... 其他模块
  ];
};
```

---

## 实施验证

### 测试清单
- [ ] `nix flake check` 通过
- [ ] `nixos-rebuild build --flake .#nixos-wsl` 成功
- [ ] 部署到 WSL 测试系统功能完整性
- [ ] 验证 home-manager 配置正确应用
- [ ] 验证所有 shell 工具正常工作

### 回滚方案
1. 使用 Git 分支进行重构：`git checkout -b refactor/drupol-pattern`
2. 每个阶段提交一次，便于回滚
3. 保留旧配置的备份分支

---

## 优势总结

### 重构后的优势
1. ✅ **去中心化**: 添加新主机只需创建 `hosts/xxx/default.nix`
2. ✅ **细粒度控制**: 每个工具独立文件，通过文件存在来控制功能
3. ✅ **声明式**: 直接声明配置，无条件逻辑
4. ✅ **自动发现**: import-tree 自动扫描，无需手动 imports
5. ✅ **清晰简洁**: 文件结构即功能列表，配置简洁易读
6. ✅ **同位配置**: 相关的 NixOS 和 Home Manager 配置在同一处
7. ✅ **易于扩展**: 添加新功能只需新建文件

### 关键差异

| 特性 | 旧架构 | 新架构 |
|------|--------|--------|
| 主机注册 | flake.nix 手动定义 | hosts/xxx/default.nix 自注册 |
| 模块发现 | 手动 imports + scanPaths | import-tree 自动扫描 |
| 功能控制 | 粗粒度（cli-tools.nix 包含多个工具） | 细粒度（每个工具独立文件） |
| 配置方式 | os/ 和 home/ 分离 | 同位定义（同一文件） |
| 默认值控制 | default.nix + mkDefault | 文件存在即启用 |
| 用户定义 | vars.nix 全局变量 | modules/users/xxx.nix 模块 |

---

## 参考资料

1. **drupol/infra**: https://github.com/drupol/infra
2. **参考文章**: https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/
3. **flake-parts**: https://flake.parts/
4. **import-tree**: https://github.com/vic/import-tree
