
# Nix 配置

此仓库包含用于 NixOS、macOS 及其他 Linux 系统的 Nix 配置。

首先，克隆本仓库：
```
git clone --recurse-submodules https://github.com/lossthannothing/nix-config.git
```

---

## 1. NixOS (含 WSL) 使用说明

在 NixOS 中，Home Manager 作为系统模块集成。所有系统级和用户级的配置通过一个命令统一管理，以保证原子性更新和配置持久化。

### 系统更新与配置切换

对于任何配置变更（系统或用户），都应在 `nix-config` 根目录运行以下命令：
```bash
# 进入配置目录
cd nix-config

# 构建并切换到新配置
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- switch --flake .#nixos-wsl
```

### 首次安装 (仅限 WSL)

此流程用于首次安装或变更 WSL 默认用户。

1.  **确认配置：** 确保 `/os/nixos-wsl.nix` 文件中已定义目标用户及 WSL 默认用户。
2.  **构建系统：** 此命令会构建新系统并使其在下次启动时生效。
    ```bash
    cd ~/nix-config
    sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- boot --flake .#nixos-wsl
    ```
3.  **重启 WSL 实例：** 在 Windows PowerShell 或 CMD 中执行。
    ```powershell
    wsl -t NixOS
    ```
4.  **验证并清理：** 重启后，系统应已使用新用户登录。确认无误后，可移除原默认用户的配置文件。
    ```bash
    sudo rm -rf /home/nixos/nix-config
    ```

---

## 2. Nix-Darwin (macOS) 使用说明

Nix-Darwin 使用 Nix 来管理整个 macOS 的系统级配置，类似于 NixOS。Home Manager 作为其模块集成，通过 `darwin-rebuild` 命令统一更新。

### 系统更新与配置切换

在 `nix-config` 根目录运行以下命令，以原子方式更新系统和用户配置：
```bash
cd nix-config
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake .
```

---

## 3. 独立 Home Manager (其他 Linux 发行版)

对于非 NixOS/Nix-Darwin 的系统，Home Manager 可作为独立工具管理用户环境。

### 应用配置

在 `nix-config` 根目录运行以下命令以应用或更新用户配置。
```bash
# 自动检测架构并应用
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .

# 或按架构显式指定
# NIX_CONFIG="..." nix run home-manager/master -- switch --flake .#loss@x86_64-linux
# NIX_CONFIG="..." nix run home-manager/master -- switch --flake .#loss@aarch64-linux
```

---

## 4. Shell 别名参考

配置生效后，以下别名可用：

```bash
# ========================
#  NixOS
# ========================
nrs          # 更新 NixOS 系统及用户环境 (nixos-rebuild switch)

# ========================
#  Nix-Darwin (macOS)
# ========================
drs          # 更新 Nix-Darwin 系统及用户环境 (darwin-rebuild switch)

# ========================
#  独立 Home Manager
# ========================
hms          # 更新用户配置 (home-manager switch)

# ========================
#  通用维护命令
# ========================
hmg          # 列出 Home Manager 的所有历史版本 (generations)
hmtoday      # 清理超过 1 天的历史版本
hmwk         # 清理超过 1 周的历史版本
hmu          # 更新 flake.lock 文件
```
