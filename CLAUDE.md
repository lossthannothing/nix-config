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

## Nix Architecture（项目特定架构）

### 核心架构模式

```
┌─────────────────────────────────────────────────────────┐
│  flake.nix                                            │
│  ┌─────────────────────────────────────────────────┐  │
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
│    dev/, shell/, base/, wsl/, users/              │
│    (自动合并到聚合模块)                             │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  hosts/（实例层）                                       │
│  ┌─────────────────────────────────────────────────┐  │
│  │  nixos-wsl/      → NixOS-WSL                │  │
│  │  fedora-wsl/     → Fedora-WSL (仅 Home Manager)│
│  └─────────────────────────────────────────────────┘  │
│  通过 imports 组装 modules 中的能力                  │
└─────────────────────────────────────────────────────────┘
```

### 目录与注册路径映射

| 目录位置 | 注册路径 | 用途 |
|---------|---------|------|
| `modules/dev/*.nix` | `homeManager.dev` | 开发工具（自动合并） |
| `modules/shell/*.nix` | `homeManager.shell` | Shell 工具（自动合并） |
| `modules/base/*.nix` | `nixos.base` + `homeManager.base` | 基础配置 |
| `modules/wsl/default.nix` | `nixos.wsl` + `homeManager.wsl` | WSL 统一配置 |
| `modules/users/loss/default.nix` | `nixos.loss` + `homeManager.loss` | 用户配置 |
| `modules/flake-parts/*.nix` | 系统生成器 | 架构核心 |

### 主机配置示例

```nix
# hosts/nixos-wsl/default.nix（完整系统）
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
        # Home Manager 集成
        {
          home-manager.users.loss = {
            imports = with config.flake.modules.homeManager; [
              base
              shell
              dev
              wsl     # WSL 用户级配置
              loss    # 用户 Home Manager 配置
            ];
          };
        }
      ];
  };
}

# hosts/fedora-wsl/default.nix（仅 Home Manager）
{config, ...}: {
  flake.modules.homeManager."hosts/fedora-wsl" = {...}: {
    imports = with config.flake.modules.homeManager; [
      base
      shell
      dev
      loss
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

# 情况4：需要 flake inputs
{inputs, ...}: {
  flake.modules.homeManager.dev = {
    programs.rust.package = inputs.rust-overlay;
  };
}
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

### 调试配置

```bash
nix flake check                              # 语法检查
nix eval .#nixosConfigurations.nixos-wsl      # 评估配置
nix repl                                      # 交互式检查
:lf .
:p outputs.nixosConfigurations.nixos-wsl.config.services
```

---

## File Permissions（文件修改权限）

### 自由修改
- `modules/*`（添加/编辑）
- `scripts/*`
- `CLAUDE.md`, `README.md`

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

---

## Success Criteria（成功标准）

1. `nix flake check` 通过
2. 代码遵循项目架构
3. 提交消息使用 `/zcf:git-commit` 生成
4. 用户可理解变更内容

---

**记住**：稳定性和可维护性比炫技更重要。简单、清晰、可预测的代码是最好的代码。
