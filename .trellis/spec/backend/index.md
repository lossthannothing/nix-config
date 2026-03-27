# Host Configuration & Infrastructure Guidelines

> Best practices for host assembly and flake-parts infrastructure.

---

## Overview

This directory contains guidelines for the **instance layer** (hosts) and **mechanism layer** (flake-parts infrastructure). Hosts assemble modules into deployable configurations. The flake-parts infrastructure provides the framework that makes everything work.

**Key concepts:**
- Hosts live in `hosts/` and compose modules by namespace references
- `host-machines.nix` is the engine that transforms hosts into `nixosConfigurations`
- flake-parts infrastructure in `modules/flake-parts/` should rarely be modified
- Deployment uses `scripts/deploy.sh` for all scenarios

---

## Guidelines Index

| Guide | Description |
|-------|-------------|
| [Directory Structure](./directory-structure.md) | hosts/ and flake-parts/ layout |
| [Deployment Guidelines](./database-guidelines.md) | Deployment methods, scripts, and procedures |
| [Troubleshooting](./error-handling.md) | Common errors and debugging techniques |
| [Infrastructure Quality](./quality-guidelines.md) | Validation, testing, and review checklist |
| [Build & Debug](./logging-guidelines.md) | Build system, REPL debugging, proxy config |

---

## Quick Reference

### Adding a new host

1. Create `hosts/<hostname>/default.nix`
2. Register to `flake.modules.nixos."hosts/<hostname>"` or `flake.modules.homeManager."hosts/<hostname>"`
3. Compose modules via `imports = with config.flake.modules.nixos; [ ... ]`
4. Run `nix flake check` to validate
5. Deploy with `./scripts/deploy.sh`

### Critical rules

- **Never** modify `modules/flake-parts/` without review approval
- **Always** validate with `nix flake check` before deploying
- **Always** use `./scripts/deploy.sh` for deployment (not raw nixos-rebuild)
- Host files should be thin — mostly `imports` + host-specific overrides

---

**Language**: All documentation is written in **English**.
