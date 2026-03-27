# Inputs & Cross-Layer References

> How to use flake inputs and access cross-layer data in modules.

---

## Overview

Modules sometimes need external data: flake inputs (for overlays, external modules) or flake-level metadata (for user info, project config). This guide explains the two mechanisms and when to use each.

---

## Flake Inputs Access

### How It Works

Flake inputs are declared in `flake.nix` and passed to all flake-parts modules via the top-level function parameter.

```nix
# modules/dev/languages/rust.nix
{ inputs, ... }: {
  flake.modules = {
    nixos.rust = {
      nixpkgs.overlays = [inputs.rust-overlay.overlays.default];
    };
    homeManager.dev = { pkgs, ... }: {
      home.packages = [pkgs.rust-bin.stable.latest.default];
    };
  };
}
```

### Available Inputs

| Input | What It Provides |
|-------|-----------------|
| `inputs.nixpkgs` | Nix packages (nixos-unstable) |
| `inputs.home-manager` | Home Manager modules |
| `inputs.nixos-wsl` | WSL NixOS modules |
| `inputs.niri` | Niri compositor modules |
| `inputs.rust-overlay` | Rust toolchain overlays |
| `inputs.catppuccin` | Catppuccin theme modules |
| `inputs.wired-notify` | Wired notification overlays + HM modules |
| `inputs.disko` | Declarative disk partitioning modules |
| `inputs.treefmt-nix` | Code formatting framework |

### Common Input Usage Patterns

**Importing external NixOS module:**
```nix
{ inputs, ... }: {
  flake.modules.nixos.disko = {
    imports = [inputs.disko.nixosModules.disko];
  };
}
```

**Injecting overlay:**
```nix
{ inputs, ... }: {
  flake.modules.nixos.rust = {
    nixpkgs.overlays = [inputs.rust-overlay.overlays.default];
  };
}
```

**Importing external HM module:**
```nix
{ inputs, ... }: {
  flake.modules.homeManager.desktop = {
    imports = [inputs.wired-notify.homeManagerModules.default];
  };
}
```

---

## Cross-Layer Reference (topLevel Pattern)

### How It Works

When a module needs to read flake-level data (like `config.flake.meta`), it uses the `topLevel` parameter:

```nix
# modules/dev/git.nix
topLevel: {
  flake.modules.homeManager.dev = { config, ... }: {
    programs.git.settings.user = {
      inherit (topLevel.config.flake.meta.users.${config.home.username}) name;
    };
  };
}
```

### The flake.meta System

Project metadata is defined via `flake.meta` (from `modules/flake-parts/flake.nix`):

```nix
# Used in modules/users/loss/default.nix
flake.meta.users.loss = {
  name = "Loss";
  email = "...";
};
```

This metadata is then accessible via `topLevel.config.flake.meta.*` in any module.

### When to Use topLevel vs inputs

| Need | Use |
|------|-----|
| External flake module/overlay | `{ inputs, ... }:` (Pattern D) |
| Project metadata (user info, etc.) | `topLevel:` (Pattern E) |
| Package references | `{ pkgs, ... }:` inside namespace value |
| Module-local config | `{ config, ... }:` inside namespace value |

---

## Parameter Scope Distinction

This is the **most common source of confusion**. There are two levels of parameters:

### Level 1: Flake-Parts Module Parameters (File Top-Level)

```nix
# These are flake-parts parameters
{ inputs, config, lib, ... }: {
  # config here = flake-parts config (contains flake.modules.*, etc.)
}

# Or named parameter
topLevel: {
  # topLevel.config = same as config above
}
```

### Level 2: NixOS/HM Module Parameters (Inside Namespace Value)

```nix
{
  flake.modules.homeManager.shell = { pkgs, config, lib, ... }: {
    # pkgs = the package set for this system
    # config = HM config (contains programs.*, home.*, etc.)
    # lib = nixpkgs lib
  };
}
```

**Critical rule:** Never confuse the two levels. `config` at the top level is the flake-parts config. `config` inside a namespace value is the NixOS/HM config.

---

## specialArgs: Passing Data to Modules

The `host-machines.nix` engine passes these `specialArgs` to all NixOS/HM modules:

| Arg | Content |
|-----|---------|
| `inputs` | All flake inputs |
| `hostConfig` | Host-specific metadata |

This means inside NixOS/HM modules (Level 2), you can also access `inputs` directly:

```nix
flake.modules.homeManager.desktop = { inputs, pkgs, ... }: {
  # inputs is available via specialArgs
};
```

However, the **recommended approach** is Pattern D (top-level `{ inputs, ... }:`) for clarity.

---

## Common Mistakes

| Mistake | Why It's Wrong | Correct Approach |
|---------|---------------|-----------------|
| Using `topLevel` just to get `inputs` | `topLevel` is for `config.flake.*` data | Use `{ inputs, ... }:` (Pattern D) |
| Accessing `config.programs.zsh` at top level | Top-level config is flake-parts config | Access inside namespace value |
| Hardcoding user info instead of using `flake.meta` | Not portable, hard to maintain | Use `topLevel.config.flake.meta.*` |
