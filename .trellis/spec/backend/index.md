# Host Configuration & Infrastructure Guidelines

> Best practices for host assembly and den framework infrastructure.

---

## Overview

This directory contains guidelines for the **host layer** and **infrastructure layer**. Hosts are defined in `modules/hosts/` and compose aspects into deployable configurations.

**Key concepts:**
- Hosts live in `modules/hosts/<hostname>/default.nix`
- Hosts register via `den.hosts.<arch>.<hostname>` and `den.aspects.<hostname>`
- Infrastructure files (`den.nix`, `nixpkgs.nix`, `formatter.nix`) should rarely be modified
- Deployment uses `scripts/deploy.sh` for all scenarios

---

## Guidelines Index

| Guide | Description |
|-------|-------------|
| [Directory Structure](./directory-structure.md) | Host and infrastructure layout |
| [Deployment Guidelines](./database-guidelines.md) | Deployment methods, scripts, and procedures |
| [Troubleshooting](./error-handling.md) | Common errors and debugging techniques |
| [Infrastructure Quality](./quality-guidelines.md) | Validation, testing, and review checklist |
| [Build & Debug](./logging-guidelines.md) | Build system, REPL debugging, proxy config |

---

## Quick Reference

### Adding a new host

1. Create `modules/hosts/<hostname>/default.nix`
2. Register host: `den.hosts.<arch>.<hostname> = {}`
3. Create aspect: `den.aspects.<hostname> = { includes = [...]; ... }`
4. Compose aspects via `includes = with loss; [ shell dev ... ]`
5. Run `nix flake check` to validate
6. Deploy with `./scripts/deploy.sh`

### Critical rules

- **Never** put host binding (`den.hosts.*.users.*`) in user modules
- **Always** validate with `nix flake check` before deploying
- **Always** use `./scripts/deploy.sh` for deployment
- Host files should be thin — mostly `includes` + host-specific overrides

---

## Architecture

```
flake.nix
    │
    ▼
modules/den.nix (framework + namespace registration)
    │
    ├── den.default (global defaults)
    │
    ├── den.aspects.loss (user definition)
    │
    ├── loss.* (reusable aspects)
    │
    └── den.hosts.x86_64-linux.nixos-wsl
        └── den.aspects.nixos-wsl (host composition)
```

---

## Host Definition Pattern

```nix
# modules/hosts/<hostname>/default.nix
{ loss, ... }: {
  # 1. Register the host
  den.hosts.x86_64-linux.<hostname> = {};

  # 2. Define host aspect with composition
  den.aspects.<hostname> = {
    # Compose aspects
    includes = with loss; [
      shell
      dev
      dev._.rust
      # ... more aspects
    ];

    # Host-specific overrides
    nixos = { ... }: {
      # System-level config
    };

    homeManager = { ... }: {
      # User-level config
    };
  };
}
```

---

**Language**: All documentation is written in **English**.
