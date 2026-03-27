# Build System & Debugging

> Build system internals, REPL debugging, and development workflows.

---

## Overview

Understanding the build system helps diagnose issues faster. This guide covers how flake evaluation works, how to use the REPL for debugging, and development workflow tips.

---

## Build System Flow

```
flake.nix
  |
  +--> import-tree ./modules  (auto-discover all .nix files)
  +--> import-tree ./hosts    (auto-discover all host configs)
  |
  v
flake-parts evaluation
  |
  +--> flake-parts.nix    (register flake.modules.* options)
  +--> host-machines.nix   (transform hosts -> nixosConfigurations)
  +--> nixpkgs.nix         (create pkgs instances)
  +--> fmt.nix             (register formatting tools)
  |
  v
nixosConfigurations / homeConfigurations
  |
  v
nixos-rebuild switch / home-manager switch
```

---

## REPL Debugging

The Nix REPL is the most powerful tool for understanding configuration state:

```bash
nix repl
:lf .   # Load the flake
```

### Common REPL Queries

**Inspect NixOS config:**
```nix
:p outputs.nixosConfigurations.nixos-wsl.config.networking.hostName
:p outputs.nixosConfigurations.nixos-wsl.config.services
:p outputs.nixosConfigurations.nixos-wsl.config.environment.systemPackages
```

**Inspect HM config:**
```nix
:p outputs.homeConfigurations."hosts/fedora-wsl".config.programs.git
:p outputs.homeConfigurations."hosts/fedora-wsl".config.home.packages
```

**Check what modules are imported:**
```nix
:p builtins.attrNames outputs.nixosConfigurations
:p builtins.attrNames outputs.homeConfigurations
```

**Explore flake metadata:**
```nix
:p outputs.nixosConfigurations.nixos-wsl.config.flake.meta
```

---

## Development Workflow

### Quick Iteration Cycle

```bash
# 1. Edit module
vim modules/shell/new-tool.nix

# 2. Format
nix fmt

# 3. Validate
nix flake check

# 4. Build (fast feedback, no deployment)
nixos-rebuild build --flake .#nixos-wsl

# 5. Deploy when ready
sudo nixos-rebuild switch --flake .#nixos-wsl
```

### Checking Config Diff

```bash
# See what would change
nixos-rebuild dry-run --flake .#nixos-wsl
```

---

## Flake Management

### View Available Outputs

```bash
nix flake show
```

### Update Dependencies

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs
nix flake update home-manager
```

### Check Flake Health

```bash
# Comprehensive validation
nix flake check

# Quick metadata check
nix flake metadata
```

---

## Proxy Configuration for WSL

WSL environments need proxy configuration for network access:

### Git Operations

```bash
/home/loss/nix-config/scripts/proxy-wrapper.sh git push
```

### General Network Access

```bash
HOST=$(ip route | awk '/default/ {print $3; exit}') && \
  http_proxy="http://${HOST}:7890" \
  https_proxy="http://${HOST}:7890" \
  <command>
```

### Available Proxy Scripts

| Script | Purpose |
|--------|---------|
| `scripts/git-proxy.sh` | Git proxy configuration |
| `scripts/shell-proxy.sh` | Shell environment proxy |
| `scripts/nixdaemon-proxy.sh` | Nix daemon proxy |
| `scripts/nix-daemon-wsl-proxy.sh` | WSL-specific Nix daemon proxy |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Not using REPL for debugging | REPL gives instant feedback on config state |
| Editing and deploying without building first | Always `build` before `switch` |
| Forgetting proxy in WSL | Use proxy-wrapper.sh for network operations |
| Running `nix flake update` without testing | Update, build, test, then commit `flake.lock` |
