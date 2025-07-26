# Suggested Commands

## NixOS System Management
```bash
# Build and switch NixOS configuration
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- switch --flake .#nixos-wsl

# Build for next boot (first-time setup)
sudo NIX_CONFIG="experimental-features = nix-command flakes" nix run github:NixOS/nixpkgs/nixos-25.05#nixos-rebuild -- boot --flake .#nixos-wsl
```

## Home Manager (Standalone)
```bash
# Apply Home Manager configuration
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .
```

## Development Commands
```bash
# Format Nix files
nixfmt-rfc-style **/*.nix

# Check flake
nix flake check

# Update flake inputs
nix flake update
```

## Git Commands
```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/lossthannothing/nix-config.git

# Update submodules
git submodule update --remote
```

## System Utilities (Linux)
- `ls`, `cd`, `grep`, `find`, `cat`, `less`, `vim`
- `git` for version control
- `nix` for package management
- `systemctl` for service management