
# Nix Configurations

This repository contains Nix configurations for NixOS, macOS, and other Linux systems.

First, clone this repository:
```
git clone --recurse-submodules https://github.com/lossthannothing/nix-config.git
```

---

## 1. NixOS (including WSL) Usage

On NixOS, Home Manager is integrated as a system module. All system-level and user-level configurations are managed uniformly through a single command to ensure atomic updates and configuration persistence.

### System Updates & Configuration Switching

For any configuration change (system or user), run the following command from the `nix-config` root directory:
```bash
# cd into the config directory
cd nix-config

# Build and switch to the new configuration
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- switch --flake .#nixos-wsl
```

### First-Time Setup (WSL Only)

This process is for the initial setup or for changing the default WSL user.

1.  **Confirm Configuration:** Ensure the target user and WSL default user are defined in `/os/nixos-wsl.nix`.
2.  **Build the System:** This command builds the new system and makes it active on the next boot.
    ```bash
    cd ~/nix-config
    sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- boot --flake .#nixos-wsl
    ```
3.  **Restart the WSL Instance:** Execute this in Windows PowerShell or CMD.
    ```powershell
    wsl -t NixOS
    ```
4.  **Verify and Clean Up:** After rebooting, the system should be logged in as the new user. Once confirmed, you can remove the original default user's configuration files.
    ```bash
    sudo rm -rf /home/nixos/nix-config
    ```

---

## 2. Nix-Darwin (macOS) Usage

Nix-Darwin uses Nix to manage system-level configurations for macOS, similar to NixOS. Home Manager is integrated as a module and updated uniformly with the system via the `darwin-rebuild` command.

### System Updates & Configuration Switching

Run the following command from the `nix-config` root to atomically update both system and user configurations:
```bash
cd nix-config
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake .
```

---

## 3. Standalone Home Manager (Other Linux Distros)

For non-NixOS/Nix-Darwin systems, Home Manager can be used as a standalone tool to manage the user environment.

### Applying the Configuration

Run the following command from the `nix-config` root to apply or update the user configuration.
```bash
# Auto-detect architecture and apply
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .

# Or specify the architecture explicitly
# NIX_CONFIG="..." nix run home-manager/master -- switch --flake .#loss@x86_64-linux
# NIX_CONFIG="..." nix run home-manager/master -- switch --flake .#loss@aarch64-linux
```

---

## 4. Shell Alias Reference

Once the configuration is applied, the following aliases will be available:

```bash
# ========================
#  NixOS
# ========================
nrs          # Update NixOS system and user environment (nixos-rebuild switch)

# ========================
#  Nix-Darwin (macOS)
# ========================
drs          # Update Nix-Darwin system and user environment (darwin-rebuild switch)

# ========================
#  Standalone Home Manager
# ========================
hms          # Update user configuration (home-manager switch)

# ========================
#  General Maintenance
# ========================
hmg          # List all Home Manager generations
hmtoday      # Remove generations older than 1 day
hmwk         # Remove generations older than 1 week
hmu          # Update the flake.lock file
```
