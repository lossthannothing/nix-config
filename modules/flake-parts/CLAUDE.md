# modules/flake-parts/

本目录是 Nix 配置的**系统生成器层**（System Generators），包含 flake-parts 框架的核心基础设施。所有文件通过根 `flake.nix` 中的 `import-tree ./modules` 自动导入。

## 文件职责

| 文件 | 职责 | 影响范围 |
|------|------|---------|
| `flake-parts.nix` | 导入 `flakeModules.modules`，启用 `config.flake.modules.*` 命名空间 | 模块注册基础 |
| `flake.nix` | 定义 `flake.meta` option（`lazyAttrsOf anything`），提供默认 `meta.uri` | 全局元数据 |
| `host-machines.nix` | **核心引擎**：将 `hosts/` 前缀模块转换为 nixosConfigurations / homeConfigurations | 生成所有主机配置 |
| `nixpkgs.nix` | 定义 `perSystem` pkgs 实例（允许全部 unfree）、flake-level `overlays.default` | 全局包策略 |
| `fmt.nix` | 配置 treefmt-nix，管理 15+ 格式化工具 | `nix fmt` |

## host-machines.nix 核心机制

这是整个架构的引擎，实现"去中心化"模块注册。两条生成管线有**关键差异**：

### nixosConfigurations（NixOS 全系统）

```nix
# 使用 mapAttrs' → 键名去除 "hosts/" 前缀
# "hosts/nixos-wsl" → nixosConfigurations."nixos-wsl"
# 部署: sudo nixos-rebuild switch --flake .#nixos-wsl
lib.pipe config.flake.modules.nixos [
  (lib.filterAttrs (name: _: lib.hasPrefix "hosts/" name))
  (lib.mapAttrs' (name: module: {
    name = lib.removePrefix "hosts/" name;  # ← 去前缀
    value = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; hostConfig.name = ...; };
      modules = [ module  home-manager-nixos-module  解绑配置 ];
    };
  }))
];
```

### homeConfigurations（独立 HM，非 NixOS）

```nix
# 使用 mapAttrs → 键名保留 "hosts/" 前缀
# "hosts/fedora-wsl" → homeConfigurations."hosts/fedora-wsl"
# 部署: home-manager switch --flake .#hosts/fedora-wsl
lib.pipe config.flake.modules.homeManager [
  (lib.filterAttrs (name: _: lib.hasPrefix "hosts/" name))
  (lib.mapAttrs (name: module:  # ← 保留前缀
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;  # 硬编码 x86_64
      modules = [ module  { targets.genericLinux.enable = true; } ];  # 自动注入兼容层
    }
  ))
];
```

### 设计决策

| 决策 | 原因 |
|------|------|
| `useGlobalPkgs = false` | 解绑 HM/NixOS pkgs 实例，允许模块独立注入 overlay（如 rust-overlay） |
| `useUserPackages = true` | 用户包安装到系统 profile |
| `specialArgs` 传递 `inputs` + `hostConfig` | 所有子模块可直接访问 flake inputs 和当前主机名 |
| homeConfigurations 自动注入 `genericLinux` | 非 NixOS 系统兼容层 |
| homeConfigurations pkgs 硬编码 `x86_64-linux` | 当前所有独立 HM 主机均为 x86_64（如需 aarch64 需修改此处） |
| nixos/hm 键名前缀处理不同 | NixOS 用 `mapAttrs'` 去前缀，HM 用 `mapAttrs` 保留前缀（历史约定） |

## nixpkgs.nix 细节

```nix
# perSystem pkgs：空 overlays，允许全部 unfree
perSystem.pkgs = import inputs.nixpkgs { allowUnfreePredicate = _pkg: true; };

# flake-level overlay：暴露本地自定义包
flake.overlays.default = _final: prev: {
  local = withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
};
```

注意：`perSystem` 的 pkgs 用于 `nix fmt`、`nix develop` 等 flake 命令；NixOS/HM 模块内的 pkgs 由各自的 `nixpkgs` 选项独立实例化。

## fmt.nix 格式化工具清单

| 语言 | 工具 |
|------|------|
| Nix | alejandra, deadnix（死代码）, statix（lint） |
| Shell | shfmt, shellcheck |
| Rust | rustfmt |
| Python | black, ruff-format, ruff-check |
| Go | gofmt, gofumpt |
| JS/TS | biome |
| Just | just |
| 数据格式 | yamlfmt, jsonfmt |

排除规则：`*.md`、`.trellis/**`、`*.task.json`、`LICENSE`。未匹配文件产生 warn。

## 常用命令

```bash
# 验证配置（修改后必须运行）
nix flake check

# 格式化代码
nix fmt

# 查看生成的主机配置
nix flake show
```

## 修改指南

### 添加格式化工具

编辑 `fmt.nix` → `perSystem.treefmt.programs.<tool>.enable = true;`

### 修改 specialArgs（影响所有模块）

编辑 `host-machines.nix` 的 `specialArgs` 块，NixOS 和 HM 两条管线都需同步修改。

### 添加 flake-level overlay

编辑 `nixpkgs.nix` → `flake.overlays.<name> = final: prev: { ... };`

### 支持新架构的独立 HM 主机

修改 `host-machines.nix:52` 的硬编码 `x86_64-linux`，改为根据主机配置动态选择。

## 依赖关系

```
flake.nix
  └─ import-tree ./modules
       └─ modules/flake-parts/
            ├─ flake-parts.nix    ← 启用 flake.modules.* 选项
            ├─ flake.nix          ← 启用 flake.meta.* 选项
            ├─ host-machines.nix  ← 消费 flake.modules.{nixos,homeManager}."hosts/*"
            │     ├─ → flake.nixosConfigurations
            │     └─ → flake.homeConfigurations
            ├─ nixpkgs.nix        ← perSystem pkgs + overlays
            └─ fmt.nix            ← perSystem treefmt
```

## 注意事项

⚠️ **高风险**：此目录变更影响整个构建系统。修改前确保：
1. 理解 flake-parts 模块系统（特别是 `config.flake.modules.*` 的工作方式）
2. 运行 `nix flake check` 验证
3. 测试所有主机类型构建（NixOS + 独立 HM）

## 参考资源

- [flake-parts 文档](https://flake.parts/)
- [treefmt-nix](https://github.com/numtide/treefmt-nix)
- [项目根 CLAUDE.md](../../CLAUDE.md) — 完整架构说明、模块命名空间注册表
