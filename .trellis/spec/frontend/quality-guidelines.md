# Code Quality Guidelines

> Tools and practices for maintaining Nix code quality.

---

## Overview

This project uses a comprehensive quality toolchain configured via `treefmt-nix` in `modules/flake-parts/fmt.nix`. All checks run with `nix fmt` and `nix flake check`.

---

## Quality Toolchain

### Nix-Specific Tools

| Tool | Purpose | What It Catches |
|------|---------|----------------|
| **alejandra** | Nix formatter | Inconsistent formatting, indentation |
| **deadnix** | Dead code detector | Unused variables, unused `inherit`, unused function args |
| **statix** | Nix linter | Anti-patterns, deprecated features, style issues |

### Other Formatters (For Non-Nix Files)

| Tool | Languages |
|------|-----------|
| shfmt + shellcheck | Shell scripts |
| rustfmt | Rust |
| black + ruff | Python |
| gofmt + gofumpt | Go |
| biome | JavaScript/TypeScript |
| yamlfmt | YAML |
| jsonfmt | JSON |

### Excluded from Formatting

- `*.md` files
- `.trellis/**` directory
- `*.task.json` files
- `LICENSE`

---

## Required Checks Before Commit

```bash
# Format all code (must pass)
nix fmt

# Validate flake configuration (must pass)
nix flake check
```

**Both commands must pass before any commit.**

---

## Code Style Rules

### Formatting (Enforced by alejandra)

- Alejandra is an opinionated formatter — do not fight it
- Let alejandra handle all indentation and line breaks
- Run `nix fmt` after every edit

### Dead Code (Enforced by deadnix)

```nix
# BAD: unused inherit
{ pkgs, lib, ... }: {  # lib is unused
  home.packages = [pkgs.git];
}

# GOOD: only destructure what you use
{ pkgs, ... }: {
  home.packages = [pkgs.git];
}
```

### Anti-Patterns (Enforced by statix)

```nix
# BAD: unnecessary let-in
let
  x = 1;
in {
  value = x;
}

# GOOD: inline when simple
{
  value = 1;
}
```

---

## Quality Checklist

Before committing any Nix module change:

- [ ] `nix fmt` passes with no changes
- [ ] `nix flake check` passes
- [ ] No unused variables (deadnix)
- [ ] Module follows the correct pattern (A-E) for its needs
- [ ] Namespace follows naming conventions (see hook-guidelines.md)
- [ ] If dual-register: system config in nixos.*, user config in homeManager.*

---

## Common Mistakes

| Mistake | How to Fix |
|---------|-----------|
| Committing without running `nix fmt` | Always run `nix fmt` before commit |
| Unused function parameters | Remove unused params or use `_` |
| Using `with pkgs;` everywhere | Explicit `pkgs.name` is preferred for clarity |
| Not running `nix flake check` | Always validate — catches type errors and eval failures |
| Ignoring statix warnings | Address them — they catch real anti-patterns |

---

## Debugging Build Failures

```bash
# Build without activating (safe to test)
nixos-rebuild build --flake .#nixos-wsl

# Dry-run to see what would change
nixos-rebuild dry-run --flake .#nixos-wsl

# Interactive REPL for debugging
nix repl
:lf .
:p outputs.nixosConfigurations.nixos-wsl.config.services
```
