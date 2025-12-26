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
├── apply_ref.sh              # 参考部署脚本（支持多平台）
├── scripts/                  # 工具脚本
├── modules/                  # 功能模块（自动扫描）
│   ├── base/                 # 基础配置（系统 + 用户）
│   ├── dev/                  # 开发工具配置
│   │   └── languages/        # 语言工具链（Rust, Nix 等）
│   ├── shell/                # Shell 配置（Zsh, Bash 等）
│   ├── desktop/              # 桌面环境配置
│   ├── users/                # 用户特定配置
│   └── flake-parts/          # Flake-parts 生成器
│       ├── host-machines.nix # 自动生成 nixosConfigurations
│       └── nixpkgs.nix       # Nixpkgs 配置
└── hosts/                    # 主机定义（自动扫描）
    └── nixos-wsl/            # WSL 主机配置
        └── default.nix       # 主机定义，自注册到 flake.modules
```

### 模块架构说明

**模块类型**：
- `flake.modules.nixos.*` - NixOS 系统层配置
- `flake.modules.homeManager.*` - Home Manager 用户层配置
- 同一功能（如 `dev`）可在一个文件中同时定义两层配置

**自动扫描机制**：
- 通过 `import-tree` 自动扫描 `modules/` 和 `hosts/` 目录
- 所有 `.nix` 文件会自动注册到 `flake.modules` 表
- 主机文件通过 `flake.modules.nixos."hosts/<name>"` 自注册

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

# 部署到当前系统（WSL）
sudo nixos-rebuild switch --flake .#nixos-wsl

# 部署 Home Manager（仅用户配置）
home-manager switch --flake .#loss@nixos-wsl

# 测试构建（不激活）
nixos-rebuild build --flake .#nixos-wsl
```

### 使用参考脚本部署

```bash
# 交互式选择部署选项
./apply_ref.sh
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
- 更新文档（README.md, AGENTS.md）

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
- **flake-parts** - 模块化 Flake 管理
- **import-tree** - 自动扫描目录
- **Home Manager** - 用户环境管理
- **NixOS-WSL** - WSL 集成
- **rust-overlay** - Rust 工具链
- **treefmt-nix** - 代码格式化

## 常见任务

### 添加新软件包

```nix
# 系统级：编辑 modules/base/system/default.nix
environment.systemPackages = with pkgs; [
  # 添加你的包
  new-package
];

# 用户级：编辑 modules/base/home/default.nix
home.packages = with pkgs; [
  new-package
];
```

### 添加新模块

1. 创建 `modules/category/default.nix`
2. 定义 `flake.modules.nixos.*` 和/或 `flake.modules.homeManager.*`
3. 在主机配置中引用该模块
4. 运行 `nix flake check` 验证

### 添加新主机

1. 创建 `hosts/hostname/default.nix`
2. 自注册：`flake.modules.nixos."hosts/hostname" = { ... };`
3. 导入所需模块
4. 配置平台特定设置（hardware, services 等）

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

## 更多信息

- 项目 README：查看 `README.md`
- NixOS 手册：https://nixos.org/manual/nixos/stable/
- Home Manager 手册：https://nix-community.github.io/home-manager/
- Flake-parts 文档：https://flake.parts/
