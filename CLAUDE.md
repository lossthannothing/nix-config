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

## 工作约定

### 代码修改原则

1. **最小化更改**：只修改与任务直接相关的代码
2. **保持一致性**：遵循现有代码风格和结构
3. **模块化优先**：新功能应创建独立模块，而非修改现有文件
4. **测试再部署**：先 `nix flake check`，再考虑 rebuild

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

## 常见任务模板

### 任务：添加新开发工具

```nix
# 1. 创建或编辑 modules/dev/tools/<tool-name>.nix
{
  flake.modules = {
    homeManager.<tool-name> = { pkgs, ... }: {
      home.packages = [ pkgs.<tool> ];
      # 配置...
    };
  };
}

# 2. 在主机配置中引用
# hosts/nixos-wsl/default.nix
home-manager.users.loss = {
  imports = with config.flake.modules.homeManager; [
    # ... 现有导入
    <tool-name>
  ];
};
```

### 任务：修改系统配置

```nix
# 编辑 modules/base/system/default.nix 或创建新模块
flake.modules.nixos.<module-name> = { pkgs, ... }: {
  # 系统级配置
  environment.systemPackages = [ ... ];
  services.<service>.enable = true;
};
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
