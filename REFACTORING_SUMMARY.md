# 架构重构完成总结

## 重构目标
将 nix-config 重构为 drupol/infra 风格的去中心化架构：
- 使用 flake-parts 模块系统
- 使用 import-tree 自动导入模块
- hosts 自注册到 `flake.modules.nixos."hosts/xxx"`
- 每个模块包含 NixOS 和 Home Manager 配置

## 完成的工作

### 1. 核心架构文件
- ✅ `flake.nix`: 使用 import-tree 自动导入 modules 和 hosts
- ✅ `modules/flake-parts/flake-parts.nix`: 启用 flake-parts 模块系统
- ✅ `modules/flake-parts/nixpkgs.nix`: 配置 pkgs 和 overlays
- ✅ `modules/flake-parts/host-machines.nix`: 自动生成 nixosConfigurations

### 2. 基础模块
- ✅ `modules/base/default.nix`: NixOS 和 Home Manager 基础配置
- ✅ `modules/users/loss.nix`: 用户配置

### 3. Shell 工具模块（modules/shell/）
- ✅ bat.nix - 代码查看器
- ✅ zoxide.nix - 智能目录跳转
- ✅ fzf.nix - 模糊查找
- ✅ lsd.nix - ls 替代品
- ✅ fd.nix - find 替代品
- ✅ sheldon.nix - Zsh 插件管理
- ✅ cli-tools.nix - 基础命令行工具
- ✅ zsh.nix - Zsh 配置

### 4. 开发工具模块（modules/dev/）
- ✅ git.nix - Git 配置
- ✅ dev-tools.nix - 开发工具和语言环境

### 5. 主机配置
- ✅ `hosts/wsl/default.nix`: WSL 主机自注册配置

### 6. 清理工作
- ✅ 移除旧架构文件到 `.old-architecture/` 目录
  - os/ 目录
  - home/ 目录
  - lib/ 目录
  - hosts/wsl/ 旧文件
  - hosts/nixos-vm/ 目录

## 关键修正

### 模块参数位置
**错误模式：**
```nix
{ pkgs, ... }:
{
  flake.modules.homeManager.shell = {
    home.packages = with pkgs; [ ... ];
  };
}
```

**正确模式：**
```nix
{
  flake.modules.homeManager.shell =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ ... ];
    };
}
```

### Hosts 文件结构
**错误模式：**
```nix
{ config, inputs, pkgs, lib, ... }:
{
  flake.modules.nixos."hosts/xxx" = {
    # pkgs、lib 在这里不可用
  };
}
```

**正确模式：**
```nix
{ config, inputs, ... }:
{
  flake.modules.nixos."hosts/xxx" =
    { pkgs, lib, ... }:  # 模块定义是一个函数
    {
      # pkgs、lib 在这里可用
      imports = with config.flake.modules.nixos; [ ... ];  # config 来自外层
    };
}
```

### dotfiles 传递
在 `modules/flake-parts/host-machines.nix` 中添加 dotfiles 到 specialArgs：
```nix
specialArgs = {
  inherit inputs;
  dotfiles = inputs.dotfiles;
  hostConfig = { ... };
};
```

## 测试结果
- ✅ `nix flake check` 通过
- ✅ `nix build .#nixosConfigurations.nixos-wsl.config.system.build.toplevel --dry-run` 成功

## 目录结构
```
nix-config/
├── flake.nix                      # 主 flake 文件
├── modules/
│   ├── flake-parts/               # flake-parts 配置
│   │   ├── flake-parts.nix
│   │   ├── nixpkgs.nix
│   │   └── host-machines.nix
│   ├── base/                      # 基础配置
│   │   └── default.nix
│   ├── users/                     # 用户配置
│   │   └── loss.nix
│   ├── shell/                     # Shell 工具
│   │   ├── bat.nix
│   │   ├── zoxide.nix
│   │   ├── fzf.nix
│   │   ├── lsd.nix
│   │   ├── fd.nix
│   │   ├── sheldon.nix
│   │   ├── cli-tools.nix
│   │   └── zsh.nix
│   └── dev/                       # 开发工具
│       ├── git.nix
│       └── dev-tools.nix
├── hosts/
│   └── wsl/
│       └── default.nix            # WSL 主机配置
└── .old-architecture/             # 旧文件备份
    ├── os/
    ├── home/
    ├── lib/
    └── ...
```

## 下一步建议
1. 测试系统重建：`sudo nixos-rebuild switch --flake .#nixos-wsl`
2. 验证所有功能正常工作
3. 如果测试通过，可以删除 `.old-architecture/` 目录
4. 提交更改到 git
5. 可选：添加更多主机配置（如 nixos-vm）
6. 可选：添加 nixos-facter-modules 和 pkgs-by-name-for-flake-parts 的实际使用

## 注意事项
- dotfiles submodule 需要存在且最新
- 所有路径引用都使用了 ${dotfiles} 变量
- lsd 和 fd 使用了 programs.xxx.enable 而不是 home.packages
- lsd 的别名由其 home-manager 模块自动提供，不需要在 zsh.nix 中重复定义
