# Namespace & Auto-Merge Rules

> How namespaces work and how modules are automatically merged.

---

## Overview

This project uses `flake.modules.*` namespaces to organize configurations. Understanding namespace rules and auto-merge behavior is critical — it's the mechanism that allows multiple files to contribute to the same configuration without conflicts.

---

## Namespace Types

### NixOS Namespaces (Fine-Grained)

Each NixOS feature gets its **own unique namespace**. Hosts must **explicitly import** each one.

```nix
# Each feature has its own namespace
flake.modules.nixos.audio = { ... };     # Audio (PipeWire)
flake.modules.nixos.bluetooth = { ... }; # Bluetooth
flake.modules.nixos.nvidia = { ... };    # NVIDIA drivers
flake.modules.nixos.fcitx5 = { ... };    # Input method
flake.modules.nixos.wsl = { ... };       # WSL config
```

**Why fine-grained?** NixOS system configs often conflict (e.g., different audio backends). Hosts must consciously choose which system features to enable.

### Home Manager Namespaces (Domain-Aggregated)

Multiple files contribute to the **same HM namespace**. All contributions are **automatically deep-merged**.

```nix
# All these files write to homeManager.shell:
# shell/zsh.nix
flake.modules.homeManager.shell = { ... }: { ... };

# shell/fzf.nix
flake.modules.homeManager.shell = { ... }: { ... };

# shell/bat.nix
flake.modules.homeManager.shell = { ... }: { ... };
```

**Why aggregated?** HM user configs rarely conflict. A shell namespace naturally contains many tools.

---

## Current Namespace Registry

### NixOS Namespaces (Explicit Import Required)

| Namespace | Source | Description |
|-----------|--------|-------------|
| `nixos.base` | `base/*.nix` | Multi-file auto-merge |
| `nixos.facter` | `base/facter.nix` | Hardware detection |
| `nixos.disko` | `base/disko.nix` | Declarative disk partitioning |
| `nixos.rust` | `dev/languages/rust.nix` | Rust overlay injection |
| `nixos.wsl` | `wsl/default.nix` | WSL system config |
| `nixos.loss` | `users/loss/default.nix` | User system config |
| `nixos.nvidia` | `desktop/nvidia.nix` | NVIDIA drivers |
| `nixos.niri` | `desktop/niri.nix` | Wayland compositor |
| `nixos.audio` | `desktop/audio.nix` | PipeWire audio |
| `nixos.bluetooth` | `desktop/bluetooth.nix` | Bluetooth support |
| `nixos.power` | `desktop/power.nix` | Power management |
| `nixos.fcitx5` | `desktop/fcitx5.nix` | Input method (NixOS+HM) |
| `nixos.swaylock` | `desktop/swaylock.nix` | PAM authentication |
| `nixos.fonts` | `desktop/fonts.nix` | System fonts |

### Home Manager Namespaces (Auto-Merged)

| Namespace | Contributing Files | Description |
|-----------|-------------------|-------------|
| `homeManager.base` | `base/home.nix`, `base/nix.nix` | HM foundation |
| `homeManager.shell` | `shell/*.nix` (11 files) | Shell tools |
| `homeManager.dev` | `dev/*.nix` (14 files) | Dev tools |
| `homeManager.desktop` | `desktop/*.nix` (14+ files) | Desktop environment |
| `homeManager.wsl` | `wsl/default.nix` | WSL user config |
| `homeManager.loss` | `users/loss/default.nix` | User HM config |

---

## Auto-Merge Behavior

### How It Works

When multiple files assign to the same namespace (e.g., `homeManager.shell`), the NixOS module system **deep-merges** them:

```nix
# From shell/zsh.nix:
flake.modules.homeManager.shell = { ... }: {
  programs.zsh.enable = true;
};

# From shell/fzf.nix:
flake.modules.homeManager.shell = { ... }: {
  programs.fzf.enable = true;
};

# Result (auto-merged):
# {
#   programs.zsh.enable = true;
#   programs.fzf.enable = true;
# }
```

### Cross-Directory Merge

Files from **different directories** can contribute to the same namespace:

```nix
# desktop/fonts.nix also contributes to homeManager.shell:
flake.modules.homeManager.shell = { pkgs, ... }: {
  home.packages = [pkgs.nerd-fonts.jetbrains-mono];
};
```

This is valid and intentional — fonts are needed by shell tools like starship.

### Merge Conflicts

If two files set the **same attribute** in the same namespace, Nix will report an error. Use `lib.mkDefault`, `lib.mkForce`, or `lib.mkMerge` to resolve:

```nix
# Use lib.mkDefault for overridable defaults
programs.bat.config.theme = lib.mkDefault "catppuccin-mocha";
```

---

## Naming New Namespaces

### Rules

| Type | Rule | Example |
|------|------|---------|
| NixOS | Name after the specific feature | `nixos.audio`, `nixos.nvidia` |
| HM | Name after the domain/category | `homeManager.shell`, `homeManager.dev` |
| Host | Use `"hosts/<hostname>"` with quotes | `nixos."hosts/nixos-wsl"` |

### When to Create a New Namespace vs. Reuse Existing

| Situation | Action |
|-----------|--------|
| New shell tool | Add to existing `homeManager.shell` |
| New dev tool | Add to existing `homeManager.dev` |
| New desktop app | Add to existing `homeManager.desktop` |
| New NixOS system service | Create new `nixos.<service-name>` |
| New NixOS hardware driver | Create new `nixos.<driver-name>` |

---

## Common Mistakes

| Mistake | Why It's Wrong | Correct Approach |
|---------|---------------|-----------------|
| Creating `homeManager.fzf` for one tool | HM namespaces aggregate by domain | Use `homeManager.shell` |
| Creating `nixos.shell` for all shell system configs | NixOS namespaces are feature-specific | Only create if needed |
| Forgetting to update this doc when adding namespaces | Future AI sessions won't know about new namespaces | Update the registry table above |
