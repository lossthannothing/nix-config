# Deployment Guidelines

> How to deploy NixOS and Home Manager configurations.

---

## Overview

This project supports multiple deployment methods through `scripts/deploy.sh`. The deploy script provides an interactive menu for common operations and CLI flags for automation.

---

## Deployment Methods

### Interactive Menu (Recommended for Daily Use)

```bash
./scripts/deploy.sh
```

Presents a menu with all available hosts and operations.

### NixOS System Rebuild

```bash
# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .#nixos-wsl
sudo nixos-rebuild switch --flake .#nixos-desktop
sudo nixos-rebuild switch --flake .#nixos-vm
```

### Home Manager Standalone Deploy

```bash
# For non-NixOS hosts (e.g., Fedora WSL)
home-manager switch --flake .#hosts/fedora-wsl
```

### Live USB Installation (New Machine)

```bash
# Uses disko for declarative disk partitioning
./scripts/deploy.sh --local nixos-desktop
```

### Remote Deployment (via nixos-anywhere)

```bash
# Deploy to a remote machine
./scripts/deploy.sh nixos-vm 192.168.122.100
```

---

## Pre-Deployment Checklist

Before deploying to any target:

- [ ] `nix fmt` passes (code is formatted)
- [ ] `nix flake check` passes (configuration is valid)
- [ ] Changes are committed (for reproducibility)
- [ ] Tested with `nixos-rebuild build --flake .#<host>` first

### Build Without Activating (Safe Test)

```bash
# Just build, don't activate
nixos-rebuild build --flake .#nixos-wsl

# See what would change
nixos-rebuild dry-run --flake .#nixos-wsl
```

---

## Available Hosts

| Host | Type | Target |
|------|------|--------|
| `nixos-wsl` | NixOS | Windows WSL environment |
| `nixos-desktop` | NixOS | Physical desktop machine |
| `nixos-vm` | NixOS | Virtual machine (testing) |
| `hosts/fedora-wsl` | Standalone HM | Fedora WSL environment |

---

## Dependency Updates

```bash
# Update all flake inputs
nix flake update

# Update a specific input
nix flake update <input-name>
```

After updating, always rebuild and test before committing the new `flake.lock`.

---

## Network Proxy (WSL-Specific)

In WSL environments, the Bash shell is non-interactive and needs explicit proxy configuration:

```bash
# Use the proxy wrapper script
/home/loss/nix-config/scripts/proxy-wrapper.sh git push

# Or set environment variables directly
HOST=$(ip route | awk '/default/ {print $3; exit}') && \
  http_proxy="http://${HOST}:7890" \
  https_proxy="http://${HOST}:7890" \
  curl https://example.com
```

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Deploying without `nix flake check` | Always validate first |
| Using raw `nixos-rebuild` in WSL | Use `./scripts/deploy.sh` which handles proxy |
| Forgetting to commit before deploy | Uncommitted changes may not be picked up |
| Updating `flake.lock` without testing | Always build and test after `nix flake update` |
