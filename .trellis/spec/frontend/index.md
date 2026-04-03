# Nix Module Development Guidelines

> Best practices for writing Nix modules using the vic/den framework.

---

## Overview

This directory contains guidelines for developing Nix modules using **vic/den** — an aspect-oriented flake framework that simplifies NixOS and Home Manager configuration.

**Key concepts:**
- **den.default** — Global defaults applied to all hosts/users
- **den.aspects** — Reusable configuration aspects (user, host, platform)
- **den.hosts** — Host definitions with user bindings
- **Custom namespaces** (e.g., `loss.*`) — User-specific aspects via `den.namespace`
- **Angle-bracket imports** — `<den/...>` and `<loss/...>` for cross-module references

---

## Guidelines Index

| Guide | Description |
|-------|-------------|
| [Directory Structure](./directory-structure.md) | Module directory layout and file organization |
| [Module Patterns](./component-guidelines.md) | The 5 aspect patterns used in this project |
| [Namespace & Aspects](./hook-guidelines.md) | Namespace naming rules and aspect composition |
| [Inputs & Cross-Layer](./state-management.md) | Using flake inputs and cross-layer references |
| [Quality Guidelines](./quality-guidelines.md) | Code quality tools: alejandra, deadnix, statix |
| [Type Safety](./type-safety.md) | Nix type system and option definitions |

---

## Quick Reference

### Adding a new aspect

1. Create `modules/<name>.nix` or `modules/<category>/<name>.nix`
2. Register to appropriate namespace: `loss.<name>` or `loss.<category>._.<name>`
3. Run `nix fmt` and `nix flake check`
4. Add to host's `includes` list in `modules/hosts/<hostname>/default.nix`

### Critical rules

- **Aspects** use `includes` to compose other aspects — not imports
- **Sub-aspects** use `._.` pattern: `loss.dev._.rust`, `loss.dev._.javascript`
- **Host binding** belongs in `modules/hosts/*/default.nix`, NOT in user modules
- **Always** run `nix fmt` before committing
- **Never** put hardcoded values in multiple places — use `let` bindings

---

## Architecture Layers

```
flake.nix (entry)
    │
    ▼
modules/den.nix (framework init + namespace registration)
    │
    ├── modules/default.nix (den.default — global settings)
    │
    ├── modules/loss.nix (den.aspects.loss — user definition)
    │
    ├── modules/shell.nix, dev.nix, wsl.nix (loss.* aspects)
    │
    ├── modules/dev/*.nix (loss.dev._.* sub-aspects)
    │
    └── modules/hosts/*/default.nix (host definitions + composition)
```

---

**Language**: All documentation is written in **English**.
