# CLAUDE.md

NixOS DevOps 工程师，精通 den 框架和 flake-parts 架构。使用简体中文响应。

## 架构概览

```
flake.nix → import-tree 自动扫描 modules/*
  den.nix → 初始化 den 框架 + 注册 "loss" 命名空间
  default.nix → den.default（全局基线）
  loss.nix → den.aspects.loss（用户 "loss"）
  system/, shell/, editors/, dev/ → loss.* 切面
  profiles/ → loss.profiles.* 平台特定偏好
  hosts/ → den.hosts.<arch>.<name> + den.aspects.<name>
```

切面通过 `includes` 聚合，主机在 `den.aspects.<host>.includes` 中组合所需切面。

## 常用命令

```bash
nix fmt                                        # 格式化 (alejandra + deadnix + statix)
nix flake check                                # 验证配置
nixos-rebuild build --flake .#nixos-wsl        # 构建但不激活
sudo nixos-rebuild switch --flake .#nixos-wsl  # 部署
./scripts/deploy.sh                            # 交互式部署菜单
```

## 网络代理 (WSL)

```bash
./scripts/git-proxy.sh git push
sudo ./scripts/nix-daemon-wsl-proxy.sh http
```

## 文件修改权限

| 自由修改 | 需要确认 |
|---------|---------|
| `modules/*`, `scripts/*`, `*.md` | `flake.nix`, `flake.lock`, `pkgs/*` |

## 参考仓库 (.ref/)

`.ref/` 目录存放外部参考仓库（gitignored）。理解配置意图后转化为 den 切面架构，不要直接复制。

```bash
./.ref/init.sh   # 首次克隆
./.ref/check.sh  # 检查是否存在
```

## 当前切面注册表

| 切面 | 文件 | 说明 |
|------|------|------|
| `den.default` | `modules/default.nix` | 全局基线 (HM 集成, zsh, sd-switch) |
| `den.aspects.loss` | `modules/loss.nix` | 用户 loss (primary-user, shell, editors) |
| `loss.system` | `modules/system/default.nix` | 聚合: nix + locale |
| `loss.system._.wsl` | `modules/system/wsl.nix` | WSL 系统配置 |
| `loss.shell` | `modules/shell/default.nix` | 聚合: zsh, starship, git, bat, eza, fd, fzf, zoxide, yazi, misc |
| `loss.editors` | `modules/editors/default.nix` | 聚合: neovim |
| `loss.dev._.tools` | `modules/dev/tools.nix` | direnv, ripgrep, ansible, devenv, hyperfine, just |
| `loss.dev._.<lang>` | `modules/dev/<lang>.nix` | go, rust, python, javascript, nix |
| `loss.profiles.wsl` | `modules/profiles/wsl.nix` | WSL 用户偏好 (aliases, Windows 集成) |
| `den.aspects.nixos-wsl` | `modules/hosts/nixos-wsl/default.nix` | WSL2 主机 |
