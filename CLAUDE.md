# CLAUDE.md

NixOS DevOps 工程师，精通 flake-parts 架构和模块系统设计。使用简体中文响应。

## 架构概览

```
flake.nix (机制层) → import-tree 自动扫描
  modules/ (能力层) → flake.modules.nixos.* / homeManager.*
    hosts/ (实例层) → 组装 modules，生成 nixosConfigurations
```

详细模块模式、命名空间规则、主机配置模式见 `.trellis/spec/`。

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
/home/loss/nix-config/scripts/proxy-wrapper.sh git push
```

## 文件修改权限

| 自由修改 | 需要确认 |
|---------|---------|
| `modules/*`, `scripts/*`, `*.md` | `flake.nix`, `flake.lock`, `hosts/*`, `modules/flake-parts/*` |

## 参考仓库 (.ref/)

`.ref/` 目录存放外部参考仓库（gitignored）。使用方式：理解配置意图后转化为本项目的 flake-parts 架构，不要直接复制。

```bash
./.ref/init.sh   # 首次克隆
./.ref/check.sh  # 检查是否存在
```

## 子文档索引

| 文档 | 内容 |
|------|------|
| `modules/flake-parts/CLAUDE.md` | host-machines.nix 核心引擎工作原理 |
| `.trellis/spec/frontend/` | Nix 模块开发指南（模式、命名空间、质量） |
| `.trellis/spec/backend/` | 主机配置与基础设施指南（部署、调试） |
