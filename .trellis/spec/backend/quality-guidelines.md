# Infrastructure Quality & Validation

> Standards for maintaining host configuration and infrastructure quality.

---

## Overview

Infrastructure quality means every configuration change is validated before deployment. This project uses Nix's built-in evaluation and the treefmt toolchain for comprehensive validation.

---

## Validation Commands

### Must-Pass Before Any Commit

```bash
# Format check (and auto-fix)
nix fmt

# Configuration validation
nix flake check
```

### Must-Pass Before Deployment

```bash
# Build the target host (without activating)
nixos-rebuild build --flake .#<hostname>

# Verify no regressions
nixos-rebuild dry-run --flake .#<hostname>
```

---

## Host Configuration Review Checklist

When adding or modifying a host configuration:

- [ ] Host follows the standard 4-section assembly pattern
- [ ] NixOS modules imported via `with config.flake.modules.nixos`
- [ ] HM modules imported via `with config.flake.modules.homeManager`
- [ ] Host-specific config is minimal (reusable config belongs in modules/)
- [ ] Namespace name uses quoted string with `/`: `"hosts/my-host"`
- [ ] `nix flake check` passes
- [ ] Can build successfully: `nixos-rebuild build --flake .#<hostname>`

---

## Infrastructure Change Review

Changes to `modules/flake-parts/` require heightened review:

### Pre-Change

- [ ] Understand what the file does (see directory-structure.md)
- [ ] Identify all downstream impacts
- [ ] Have a rollback plan

### Post-Change

- [ ] `nix flake check` passes
- [ ] **All hosts** can still build (not just the one you're working on)
- [ ] Test with at least one `nixos-rebuild build` and one `home-manager build`

---

## Forbidden Patterns

| Pattern | Why It's Dangerous | Alternative |
|---------|-------------------|-------------|
| Modifying `host-machines.nix` without full testing | Breaks all host generation | Test all hosts after change |
| Removing a namespace that hosts depend on | Breaks hosts that import it | Check all hosts before removing |
| Changing `specialArgs` without updating consumers | Modules that use specialArgs will break | Search all modules for usage |
| Adding untested overlays to `nixpkgs.nix` | Can break package resolution globally | Test overlay in isolation first |

---

## File Modification Permissions

| Area | Permission Level |
|------|-----------------|
| `modules/*` (add/edit) | Free to modify |
| `scripts/*` | Free to modify |
| `CLAUDE.md`, `README.md` | Free to modify |
| `flake.nix` or `flake.lock` | **Requires confirmation** |
| `hosts/*` | **Requires confirmation** |
| `modules/flake-parts/*` | **Requires confirmation** |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Testing only one host after infra change | Test ALL hosts: `nix flake check` covers this |
| Adding host-specific config to modules/ | Keep it in hosts/ — modules are for reusable capabilities |
| Not building before deploying | Always `nixos-rebuild build` before `switch` |
| Modifying flake-parts/ without understanding the impact | Read the file's purpose in directory-structure.md first |
