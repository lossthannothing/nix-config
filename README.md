# Nix Configuration

This repository manages my Nix configurations for various operating systems.

First download nix-config in cli
```
git clone --recurse-submodules https://github.com/lossthannothing/nix-config.git
```

---

## Home Manager

Applies your user environment configuration. Run these after your NixOS or Nix-Darwin system is set up and you're logged in as the intended user.

```bash
# Linux (ARM)
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#linux

# Linux (x86_64, e.g., WSL)
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#x86_64-linux

# macOS
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#darwin
````

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
    sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- boot --flake .#LossNixOS-WSL
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
    NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#x86_64-linux
    ```
5. **Clear Up Default User Config**: Clear up default user's nix-config from github
    ```bash
    sudo rm -rf /home/nixos/nix-config
    ```
  
### Daily System Updates

For routine updates to your NixOS WSL2 system configuration (e.g., adding packages, changing services), you can use `--switch` for immediate application.

```bash
cd nix-config
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- switch --flake .#LossNixOS-WSL
```
