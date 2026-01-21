# CLAUDE.md

本文件为 Claude（Anthropic AI 助手）提供项目特定的上下文和指导。

## 项目身份

这是一个个人 NixOS 配置仓库，采用现代化模块架构：

- **架构模式**：[drupol/infra](https://github.com/drupol/infra) 启发的去中心化模块系统
- **核心技术**：NixOS + flake-parts + Home Manager
- **主要平台**：NixOS-WSL (Windows Subsystem for Linux)
- **用户**：loss

## 快速理解架构

### 三层结构

1. **flake.nix** - 机制层
   - 定义 inputs（依赖）
   - 引入 flake-parts 和 import-tree
   - 不直接定义 nixosConfigurations

2. **modules/** - 能力层
   - 定义功能模块（base, dev, shell 等）
   - 每个模块可同时包含 NixOS 和 Home Manager 配置
   - 通过 `flake.modules.nixos.*` 和 `flake.modules.homeManager.*` 注册

3. **hosts/** - 实例层
   - 每台机器在自己的目录下自注册
   - 通过引用 modules 组装配置
   - 由 `modules/flake-parts/host-machines.nix` 自动生成系统

### 自动化机制

```nix
# import-tree 自动扫描这些目录：
(inputs.import-tree ./modules)  # 扫描所有功能模块
(inputs.import-tree ./hosts)    # 扫描所有主机配置
```

主机自注册示例：
```nix
# hosts/nixos-wsl/default.nix
flake.modules.nixos."hosts/nixos-wsl" = {
  imports = [
    # 引用 modules/ 中定义的能力
    config.flake.modules.nixos.base
    config.flake.modules.nixos.rust
  ];
};
```

### flake-parts 模块系统（关键！必读！）

**⚠️ 重要：flake-parts 模块的写法与普通 flake 完全不同！**

#### 错误写法 ❌

```nix
# modules/shell/tool.nix - 这是 flake-parts 模块
{
  flake.modules.homeManager.shell = {pkgs, ...}: {  # ❌ 错误！
    programs.tool.enable = true;
  };
}
```

**为什么错误**：
- 这里你是在 **定义一个 flake 输出值**（`flake.modules.homeManager.shell`）
- 这个值本身应该 **就是** 一个 Home Manager 模块（一个函数）
- 你不应该在 flake-parts 层面去"构造"或"包装"这个模块
- 模块的参数（`pkgs`, `config` 等）会在 **被 imports 时** 由 Home Manager/NixOS 系统传入

#### 正确写法 ✅

```nix
# modules/shell/tool.nix - flake-parts 模块
{
  flake.modules.homeManager.shell = {  # ✅ 简洁写法：直接 attrset
    programs.tool.enable = true;
  };
}

# 或者明确的函数形式
{
  flake.modules.homeManager.shell = _: {  # ✅ 明确写法：无参数函数
    programs.tool.enable = true;
  };
}

# 或者如果需要访问 flake-parts 的参数
{config, inputs, ...}: {
  flake.modules.homeManager.shell = {  # ← 外层接收 flake-parts 参数
    programs.tool = {
      enable = true;
      package = inputs.some-input.packages.tool;  # 可以引用 inputs
    };
  };
}

# 如果需要 pkgs（必须使用函数形式）
{
  flake.modules.homeManager.shell = {pkgs, ...}: {  # ← 必须！不能省略
    home.packages = [pkgs.tool];
  };
}
```

#### 核心理解

```
┌──────────────────────────────────────┐
│  modules/shell/tool.nix              │  ← flake-parts 模块
│  ┌────────────────────────────────┐  │
│  │ { ... }: {                     │  │  ← 接收 flake-parts 参数
│  │   flake.modules.homeManager... │  │     (config, inputs, self, etc.)
│  │     = _: {                     │  │  ← 定义 Home Manager 模块
│  │         programs.tool = ...    │  │     (稍后被 imports 时才执行)
│  │       };                       │  │
│  │ }                              │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘

                  ↓ import-tree 扫描

┌──────────────────────────────────────┐
│  flake.modules.homeManager.shell     │  ← 输出到 flake
│  = _: { programs.tool = ...; }       │  ← 这是一个 Home Manager 模块
└──────────────────────────────────────┘

                  ↓ hosts 中 imports

┌──────────────────────────────────────┐
│  hosts/nixos-wsl/default.nix         │
│  home-manager.users.loss = {         │
│    imports = [                       │
│      config.flake.modules...shell    │  ← 在这里被 import
│    ];                                │
│  }                                   │
└──────────────────────────────────────┘

                  ↓ Home Manager 调用

Home Manager 传入 {pkgs, config, lib, ...}
执行模块函数，获得配置
```

#### flake-parts 模块自动合并

**关键特性**：多个模块可以定义同一选项，flake-parts 会自动合并：

```nix
# modules/shell/zsh.nix
{
  flake.modules.homeManager.shell = _: {
    programs.zsh.envExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
}

# modules/shell/zoxide.nix
{
  flake.modules.homeManager.shell = _: {
    programs.zoxide.enable = true;
    programs.zsh.envExtra = ''  # ✅ 不会冲突！会自动追加
      eval "$(zoxide init zsh)"
    '';
  };
}
```

**结果**：`programs.zsh.envExtra` 会包含两个模块的内容，自动合并成一个字符串。

#### 何时需要使用 {pkgs, ...} 参数

**关键规则**：仅当需要访问 pkgs 时才必须使用函数形式。

```nix
# ✅ 情况1：工具有 programs.<tool>.enable 选项（被 Home Manager 支持）
# 可以用简洁的 attrset 形式
{
  flake.modules.homeManager.shell = {
    programs.zoxide = {    # zoxide 有 Home Manager 模块
      enable = true;
      options = ["--cmd cd"];
    };
  };
}

# ✅ 情况2：工具没有 Home Manager 支持，只能用 home.packages
# 必须使用 {pkgs, ...}: 函数形式来访问 pkgs
{
  flake.modules.homeManager.shell = {pkgs, ...}: {  # ← 必须！
    home.packages = with pkgs; [
      lstr    # lstr 没有 programs.lstr.enable
      ripgrep
    ];
  };
}

# ✅ 情况3：需要自定义包来源（从 flake inputs 获取）
{inputs, ...}: {  # ← 外层接收 flake-parts 参数
  flake.modules.homeManager.shell = {
    programs.tool.package = inputs.some-input.packages.tool;
  };
}

# ❌ 错误：需要 pkgs 但忘记写函数参数
{
  flake.modules.homeManager.shell = {  # ❌ 错误！pkgs 未定义
    home.packages = [pkgs.tool];  # 这里的 pkgs 从哪来？
  };
}
```

**快速判断方法**：
1. 检查 [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml) 是否有 `programs.<tool>` 选项
2. 有 → 用简洁的 attrset `{ programs.<tool>.enable = true; }`
3. 没有，需要 `home.packages` → **必须**用 `{pkgs, ...}: { home.packages = [...]; }`

#### 快速检查清单

写 `modules/` 下的文件时：
1. ✅ 我写的是 `flake.modules.xxx = ...`
2. ✅ 等号右边是一个函数 `_: { ... }` 或 `{pkgs, ...}: { ... }`
3. ✅ 函数体内是纯粹的 NixOS/Home Manager 配置
4. ✅ 如果需要访问 flake inputs，在外层接收参数
5. ❌ 我没有写成 `flake.modules.xxx = { pkgs, ...}: { ... }: { ... }` 这种嵌套

### 模块注册规则（重要！）

**关键原则**：`modules/dev/` 和 `modules/shell/` 下的所有模块都**自动合并**到对应的聚合模块中，无需手动在 hosts/ 中逐一导入。

#### 目录与注册路径映射

| 目录位置 | 模块注册路径 | 主机导入方式 | 说明 |
|---------|------------|------------|-----|
| `modules/dev/*.nix` | `homeManager.dev` | `dev` | 自动合并所有开发工具 |
| `modules/shell/*.nix` | `homeManager.shell` | `shell` | 自动合并所有 shell 工具 |
| `modules/base/*.nix` | `nixos.base` / `homeManager.base` | `base` | 基础配置 |
| `modules/users/loss/` | `homeManager.loss` | `loss` | 用户特定配置 |

#### 标准模块模板

**开发工具模块**（放在 `modules/dev/`）：
```nix
# modules/dev/toolname.nix

# 情况1：工具有 programs.<tool>.enable 选项（如 direnv, git 等）
{
  flake.modules.homeManager.dev = {
    programs.toolname = {
      enable = true;
      # ... 其他配置
    };
  };
}

# 情况2：工具没有 Home Manager 支持（如 jq, ripgrep 等）
{
  flake.modules.homeManager.dev = {pkgs, ...}: {  # ← 必须有 pkgs 参数！
    home.packages = with pkgs; [
      toolname
      another-tool
    ];
  };
}
```

**Shell 工具模块**（放在 `modules/shell/`）：
```nix
# modules/shell/toolname.nix

# 情况1：有 programs.<tool>.enable（如 zoxide, fzf, bat 等）
{
  flake.modules.homeManager.shell = {
    programs.toolname = {
      enable = true;
      # ... 配置
    };
  };
}

# 情况2：只能用 home.packages（如 lstr 等）
{
  flake.modules.homeManager.shell = {pkgs, ...}: {  # ← 必须有 pkgs 参数！
    home.packages = with pkgs; [toolname];
  };
}
```

**系统级模块**（放在 `modules/` 下）：
```nix
# modules/category/name.nix
{
  flake.modules.nixos.modulename = {
    # NixOS 系统级配置
    services.xxx.enable = true;
  };
}
```

#### 自动合并机制示例

创建 `modules/dev/direnv.nix` 后：
```nix
# modules/dev/direnv.nix
{
  flake.modules.homeManager.dev = {
    programs.direnv.enable = true;
  };
}
```

**不需要**在 `hosts/nixos-wsl/default.nix` 中修改任何内容！因为：
```nix
# hosts/nixos-wsl/default.nix（已存在）
home-manager.users.loss = {
  imports = with config.flake.modules.homeManager; [
    dev    # ← 这个导入会自动包含所有 modules/dev/*.nix
    shell  # ← 这个导入会自动包含所有 modules/shell/*.nix
  ];
};
```

#### 快速参考

**添加新工具时的决策树**：
1. 是开发工具？→ 放 `modules/dev/`，注册到 `homeManager.dev`
2. 是 shell 工具？→ 放 `modules/shell/`，注册到 `homeManager.shell`
3. 是系统服务？→ 放 `modules/`，注册到 `nixos.<name>`，需在 hosts 中手动导入
4. 是用户配置？→ 放 `modules/users/loss/`，注册到 `homeManager.loss`

## 工作约定

### Claude Code 环境限制

**重要：网络代理配置**

Claude Code 的 Bash 工具运行在非交互式环境中，无法直接使用 `proxy` 函数。当需要执行网络操作时（如 `git push`），必须使用代理包装器：

```bash
# ❌ 错误 - 无法使用 proxy 函数
proxy on http 7890
git push

# ✅ 正确 - 使用代理包装器
/home/loss/nix-config/scripts/proxy-wrapper.sh git push

# 或者直接设置环境变量（单条命令）
HOST=$(ip route | awk '/default/ {print $3; exit}') && \
  http_proxy="http://${HOST}:7890" \
  https_proxy="http://${HOST}:7890" \
  git push
```

**可用的代理脚本**：
- `scripts/proxy-wrapper.sh` - 命令包装器，用法：`proxy-wrapper.sh <command>`
- `scripts/set-proxy.sh` - 用于 source 设置环境变量（但每次 Bash 调用都是独立进程）

### 优先使用的现代化工具

本项目已配置现代化命令行工具，**必须优先使用这些工具**而非传统命令：

| 传统命令 | 现代替代 | 说明 | 配置位置 |
|---------|---------|------|---------|
| `find` | `fd` | 更快的文件查找，自动忽略 .git | `modules/shell/fd.nix` |
| `grep` | `rg` (ripgrep) | 更快的文本搜索，自动忽略 .git | `modules/dev/ripgrep.nix` |
| `ls` | `eza` | 现代文件列表，支持 tree、git 状态 | `modules/shell/eza.nix` |
| `cat` | `bat` | 语法高亮、行号、Git 集成 | `modules/shell/bat.nix` |
| `cd` | `z` (zoxide) | 智能目录跳转，`cdi` 交互选择 | `modules/shell/zoxide.nix` |
| `tree` | `eza --tree` | 现代化目录树展示 | `modules/shell/eza.nix` |

**示例**：
```bash
# ❌ 不要用
find . -name "*.nix" -type f

# ✅ 应该用
fd --extension nix

# ❌ 不要用
grep -r "flake.modules" .

# ✅ 应该用
rg "flake.modules"

# ❌ 不要用
tree -L 3

# ✅ 应该用
eza --tree --level=3
```

**注意**：Glob 和 Grep 工具是例外，它们是 Claude Code 的内置工具，可以正常使用。

### 代码修改原则

1. **最小化更改**：只修改与任务直接相关的代码
2. **保持一致性**：遵循现有代码风格和结构
3. **模块化优先**：新功能应创建独立模块，而非修改现有文件
4. **测试再部署**：先 `nix flake check`，再考虑 rebuild
5. **网络操作**：所有需要网络的命令（git push, curl 等）必须使用代理包装器
6. **优先现代工具**：使用上述现代化工具替代传统命令
7. **专业注释风格**：代码注释应使用技术性描述，说明代码的功能、用途或实现逻辑，禁止使用批注式注释（如"这里删除了xxx"、"这里添加了xxx"、"这个功能是为了xxx"）

### 文件修改权限

**可以自由修改**：
- `modules/` 下的功能模块（添加/编辑）
- 文档文件（README.md, AGENTS.md, CLAUDE.md）
- `scripts/` 下的工具脚本

**需要用户确认**：
- `flake.nix` 或 `flake.lock`（影响全局依赖）
- `hosts/` 下的主机配置（影响系统行为）
- `modules/flake-parts/` 下的生成器（架构核心）

**避免修改**：
- Git 配置和历史
- `dotfiles/` 子模块（由外部仓库管理）

### 交互风格

- **使用简体中文**响应（用户在 `.claude/CLAUDE.md` 中设置）
- **直接给出方案**，避免过度解释
- **展示代码差异**时使用清晰的格式
- **提供可执行命令**，而非抽象描述
- **优先参考本文档**：对于标准任务（添加工具、修改配置等），直接使用上面的模板，不要使用 Glob/Read 等工具探索现有代码，除非遇到非标准情况

## 常见任务模板

### 任务：添加新开发工具（最常用）

```nix
# 创建 modules/dev/<tool-name>.nix（仅此一步！）

# 情况1：工具有 programs.<tool>.enable 选项
# 查询：https://nix-community.github.io/home-manager/options.xhtml
{
  flake.modules.homeManager.dev = {
    programs.<tool> = {
      enable = true;
      # 配置...
    };
  };
}

# 情况2：工具没有 Home Manager 支持
{
  flake.modules.homeManager.dev = {pkgs, ...}: {  # ← 必须有 pkgs 参数！
    home.packages = with pkgs; [
      <tool>
      <another-tool>  # 可以一次添加多个
    ];
  };
}
# 无需修改 hosts/ 配置，自动生效！
```

### 任务：添加新 Shell 工具

```nix
# 创建 modules/shell/<tool-name>.nix

# 情况1：有 programs.<tool>.enable（如 zoxide, fzf, starship 等）
{
  flake.modules.homeManager.shell = {
    programs.<tool> = {
      enable = true;
      # 配置...
    };
  };
}

# 情况2：没有 Home Manager 支持（如 lstr 等）
{
  flake.modules.homeManager.shell = {pkgs, ...}: {  # ← 必须有 pkgs 参数！
    home.packages = with pkgs; [<tool>];
  };
}
# 无需修改 hosts/ 配置，自动生效！
```

### 任务：添加系统服务

```nix
# 创建 modules/<category>/<name>.nix
{
  flake.modules.nixos.<module-name> = {
    services.<service>.enable = true;
    # 其他系统级配置...
  };
}
```

然后在 hosts/nixos-wsl/default.nix 中手动导入：
```nix
imports = with config.flake.modules.nixos; [
  base
  <module-name>  # ← 添加这行
];
```

### 任务：调试配置问题

```bash
# 1. 检查语法和评估
nix flake check

# 2. 查看详细错误栈
nix eval .#nixosConfigurations.nixos-wsl --show-trace

# 3. 测试构建（不激活）
nixos-rebuild build --flake .#nixos-wsl

# 4. 检查特定选项值
nix repl
:lf .
:p outputs.nixosConfigurations.nixos-wsl.config.<path.to.option>
```

## 项目特定知识

### Rust 环境

- 使用 `rust-overlay` 提供最新 Rust 工具链
- 配置位于 `modules/dev/languages/rust.nix`
- Overlay 在 `modules/flake-parts/nixpkgs.nix` 中注入

### WSL 特定配置

主要在 `hosts/nixos-wsl/default.nix` 中定义：
- 自定义启动器（Windsurf, MCPS）
- Windows 路径集成
- Docker Desktop 集成
- 环境变量和别名

### 用户配置

- 主用户：`loss`
- 用户特定配置在 `modules/users/loss.nix` 和 `modules/users/loss/`
- Home Manager 配置通过主机定义中的 `home-manager.users.loss` 加载

## 响应格式建议

### 回答问题时

1. 直接给出答案
2. 必要时提供代码示例
3. 指出相关文件位置（使用 `file:line` 格式）
4. 如果涉及多个文件，列出清单

### 执行任务时

1. 说明计划要做什么
2. 展示将要修改的代码（修改前后对比）
3. 执行修改
4. 提供验证命令
5. 总结所做的更改

### 建议方案时

1. 简要说明问题
2. 列出 2-3 个可选方案
3. 推荐最优方案（说明理由）
4. 等待用户确认后再执行

## 限制与边界

### 不要做的事

- 不要在未经确认的情况下执行 `nixos-rebuild switch`
- 不要修改 Git 提交历史
- 不要自动推送代码到远程仓库
- 不要硬编码敏感信息（路径、密码等）
- 不要破坏现有的模块化架构

### 遇到不确定时

- 询问用户意图
- 提供多个选项让用户选择
- 解释潜在影响
- 建议先测试后部署

## 参考资源

当需要查阅 Nix 语法或 NixOS 选项时：

- NixOS Options: https://search.nixos.org/options
- Nix Packages: https://search.nixos.org/packages
- Home Manager Options: https://nix-community.github.io/home-manager/options.xhtml
- Flake-parts 文档: https://flake.parts/

## 成功标准

一个任务成功完成的标志：

1. ✅ `nix flake check` 通过
2. ✅ 相关文件已更新
3. ✅ 代码符合项目风格
4. ✅ 用户可以理解所做的更改
5. ✅ 提供了验证或部署命令

## 项目维护者信息

- 用户名：loss
- WSL 用户：Lossilklauralin
- 主要工作环境：Windows + WSL NixOS
- 配置风格：模块化、可维护、遵循最佳实践

---

**记住**：这是用户的个人配置，稳定性和可维护性比炫技更重要。简单、清晰、可预测的代码是最好的代码。
