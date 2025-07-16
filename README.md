# Nix Configuration

This repository manages my Nix configurations for various operating systems.

First download nix-config in cli
```
git clone --recurse-submodules https://github.com/lossthannothing/nix-config.git
```

---

## Home Manager

Applies your user environment configuration. Run these after your NixOS or Nix-Darwin system is set up and you're logged in as the intended user.

### Recommended Usage (Auto-detect Architecture)

```bash
# Simplest: Auto-detect current system architecture
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .
```

### Architecture-Specific Usage

```bash
# Linux (x86_64, e.g., WSL, most desktops)
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#loss@x86_64-linux

# Linux (ARM64, e.g., Raspberry Pi, Apple Silicon Linux VMs)
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#loss@aarch64-linux

# macOS (Intel)
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#loss@x86_64-darwin

# macOS (Apple Silicon)
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#loss@aarch64-darwin
```

### Alternative: Using Username

```bash
# Explicit username (same as auto-detect)
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#loss
```

### Legacy Usage (Backward Compatibility)

```bash
# Linux (ARM) - legacy alias
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#linux

# Linux (x86_64) - legacy alias
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#x86_64-linux
```

-----

## Nix-Darwin (macOS)

Builds and switches your Nix-Darwin system configuration. Run this from the root of your `nix-config` directory.

```bash
cd nix-config
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run nix-darwin/nix-darwin-25.05#darwin-rebuild -- switch --flake .
```

-----

## NixOS in WSL

Guides the setup and updates for your NixOS WSL2 system. Run these commands from the root of your `nix-config` directory.

### Initial Setup & User Change

For first-time setup or changing the default user from `nixos` to your configured user (e.g., `loss`).

1.  **Confirm Configuration:** Ensure `/os/nixos-wsl.nix` includes the user and default WSL user settings:
    ```nix
    # /os/nixos-wsl.nix
    users.users.loss = {
      isNormalUser = true;
      description = "loss";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
    wsl.defaultUser = "loss";
    ```
2.  **Build System Configuration:** In your WSL shell, build and prepare the new system generation for the next boot.
    ```bash
    cd ~/nix-config
    sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- boot --flake .#nixos-wsl
    ```
3.  **Restart WSL Instance:** Execute in **Windows PowerShell or CMD** to apply the default user change.
    ```powershell
    wsl -t NixOS
    wsl -d NixOS --user root exit
    wsl -t NixOS
    ```
4.  **Activate Home Manager:** Re-open your WSL shell. Once confirmed logged in as `loss`, activate your Home Manager configuration.
    ```bash
    cd ~/nix-config
    NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .
    ```
5. **Clear Up Default User Config**: Clear up default user's nix-config from github
    ```bash
    sudo rm -rf /home/nixos/nix-config
    ```
  
### Daily System Updates

For routine updates to your NixOS WSL2 system configuration (e.g., adding packages, changing services), you can use `--switch` for immediate application.

```bash
cd nix-config
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- switch --flake .#nixos-wsl
```

---

## Quick Reference

### Shell Aliases (Available after Home Manager setup)

```bash
# Home Manager
hms          # Switch Home Manager config (auto-detect architecture)
hms-x86      # Switch to x86_64-linux config
hms-arm      # Switch to aarch64-linux config

# Maintenance
hmg          # Show Home Manager generations
hmtoday      # Remove generations older than 1 day
hmwk         # Remove generations older than 1 week
hmu          # Update flake inputs
```
