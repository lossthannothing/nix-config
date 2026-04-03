# Host & Infrastructure Directory Structure

> How hosts and infrastructure are organized in the den framework.

---

## Overview

The project uses vic/den framework with a simplified structure:
- `modules/hosts/` — Host definitions that compose aspects into deployable systems
- Infrastructure files at `modules/` root — Framework configuration

---

## Hosts Directory Layout

```
modules/hosts/
└── <hostname>/
    └── default.nix      # Host registration + aspect composition
```

### Current Hosts

| Host | Location | Description |
|------|----------|-------------|
| nixos-wsl | `modules/hosts/nixos-wsl/default.nix` | NixOS on WSL2 |

---

## Infrastructure Files

```
modules/
├── den.nix          # Framework init + namespace registration
├── default.nix      # den.default — global defaults
├── nixpkgs.nix      # perSystem pkgs + flake overlays
├── formatter.nix    # treefmt-nix configuration
├── loss.nix         # den.aspects.loss — user definition
├── shell.nix        # loss.shell — shell tools
├── dev.nix          # loss.dev — dev tools
├── wsl.nix          # loss.wsl — WSL platform
└── dev/             # Language-specific sub-aspects
```

### What Each File Does

| File | Role | Impact of Breaking It |
|------|------|----------------------|
| `den.nix` | Loads den flakeModule, registers namespaces | All aspect system stops working |
| `default.nix` | Global defaults (nix, locale, HM) | All hosts lose base configuration |
| `nixpkgs.nix` | perSystem pkgs, overlays | Package resolution breaks |
| `formatter.nix` | treefmt configuration | `nix fmt` stops working |

**CRITICAL**: Modifying `den.nix`, `nixpkgs.nix`, or `formatter.nix` requires review.

---

## Host Definition Pattern

All hosts follow this pattern:

```nix
# modules/hosts/<hostname>/default.nix
{ loss, ... }: {
  # 1. Register the host
  den.hosts.x86_64-linux.<hostname> = {};

  # 2. Define host aspect
  den.aspects.<hostname> = {
    # 3. Compose aspects
    includes = with loss; [
      shell
      dev
      dev._.rust
      dev._.javascript
      # ... more aspects
    ];

    # 4. Host-specific overrides
    nixos = { ... }: {
      # System-level config
      wsl.defaultUser = "loss";
    };

    homeManager = { ... }: {
      # User-level config (optional)
    };
  };
}
```

### Structure Breakdown

1. **Host registration**: `den.hosts.<arch>.<hostname> = {}`
2. **Aspect definition**: `den.aspects.<hostname> = { ... }`
3. **Composition**: `includes = with loss; [ ... ]`
4. **Overrides**: `nixos` and/or `homeManager` sections

---

## Adding a New Host

1. Create `modules/hosts/<hostname>/default.nix`
2. Register host: `den.hosts.x86_64-linux.<hostname> = {}`
3. Define aspect: `den.aspects.<hostname> = { ... }`
4. Compose aspects via `includes`
5. Add host-specific overrides
6. Run `nix flake check` to validate

### Example: Adding a Desktop Host

```nix
# modules/hosts/nixos-desktop/default.nix
{ loss, ... }: {
  den.hosts.x86_64-linux.nixos-desktop = {};

  den.aspects.nixos-desktop = {
    includes = with loss; [
      shell
      dev
      dev._.rust
      # Add desktop aspects when available
    ];

    nixos = { ... }: {
      networking.hostName = "nixos-desktop";
      # Desktop-specific config
    };
  };
}
```

---

## Namespace Registration

New user namespaces are registered in `modules/den.nix`:

```nix
{ inputs, den, ... }: {
  _module.args.__findFile = den.lib.__findFile;
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "loss" true)  # Register "loss" namespace
    # Add more namespaces as needed:
    # (inputs.den.namespace "another-user" true)
  ];
}
```

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Using `imports` instead of `includes` | Aspects use `includes` for composition |
| Host binding in user module | Put `den.hosts.*` in host config only |
| `loss.dev.rust` instead of `loss.dev._.rust` | Sub-aspects use `._.` pattern |
| Modifying den.nix without review | Always get review approval first |
| Putting reusable config in hosts/ | Move to aspect files in `modules/` |

---

## Migration Notes

If migrating from the old flake-parts structure:

| Old Location | New Location |
|--------------|--------------|
| `hosts/<hostname>/` | `modules/hosts/<hostname>/` |
| `modules/flake-parts/host-machines.nix` | Handled by den framework |
| `modules/base/*.nix` | `modules/default.nix` (merged) |
| `modules/shell/*.nix` | `modules/shell.nix` (merged) |
| `modules/dev/*.nix` | `modules/dev.nix` + `modules/dev/*.nix` |
| `flake.modules.nixos.*` | `den.aspects.*` or `loss.*` |
| `flake.modules.homeManager.*` | `*.homeManager` in aspects |
