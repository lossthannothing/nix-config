# Nix Module Development Guidelines

> Best practices for writing Nix modules in this flake-parts project.

---

## Overview

This directory contains guidelines for developing Nix modules — the **capability layer** of the project's three-layer architecture. Modules live in `modules/` and define reusable NixOS and Home Manager configurations.

**Key concepts:**
- Modules register to `flake.modules.nixos.*` or `flake.modules.homeManager.*` namespaces
- Multiple files can contribute to the same namespace (auto-merge)
- `import-tree` automatically discovers all `.nix` files — no manual import lists
- Hosts assemble modules by referencing their namespace names

---

## Guidelines Index

| Guide | Description |
|-------|-------------|
| [Directory Structure](./directory-structure.md) | Module directory layout and file organization |
| [Module Patterns](./component-guidelines.md) | The 5 module writing patterns used in this project |
| [Namespace & Auto-Merge](./hook-guidelines.md) | Namespace naming rules and auto-merge behavior |
| [Inputs & Cross-Layer](./state-management.md) | Using flake inputs and cross-layer references |
| [Quality Guidelines](./quality-guidelines.md) | Code quality tools: alejandra, deadnix, statix |
| [Type Safety](./type-safety.md) | Nix type system and option definitions |

---

## Quick Reference

### Adding a new module

1. Create `modules/<category>/<name>.nix`
2. Register to appropriate namespace: `flake.modules.nixos.<name>` or `flake.modules.homeManager.<category>`
3. Run `nix fmt` and `nix flake check`
4. Add to host imports if NixOS namespace (HM namespaces auto-merge)

### Critical rules

- **NixOS namespaces** = fine-grained (one per feature): `nixos.audio`, `nixos.nvidia`
- **HM namespaces** = domain-aggregated (many files per namespace): `homeManager.shell`, `homeManager.dev`
- **Never** manually list imports in `flake.nix` — `import-tree` handles discovery
- **Always** run `nix fmt` before committing

---

**Language**: All documentation is written in **English**.
