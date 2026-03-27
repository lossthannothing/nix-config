# Module Directory Structure

> How Nix modules are organized in this project.

---

## Overview

All reusable configurations live in `modules/`. The `import-tree` flake input automatically discovers every `.nix` file recursively — no manual import lists needed. Each file registers its configuration to one or more `flake.modules.*` namespaces.

---

## Directory Layout

```
modules/
|-- flake-parts/             # Framework infrastructure (DO NOT touch without review)
|   |-- flake-parts.nix      # Enables flake.modules.* namespace options
|   |-- flake.nix            # flake.meta option (user metadata)
|   |-- host-machines.nix    # Core engine: hosts/ -> nixosConfigurations
|   |-- nixpkgs.nix          # perSystem pkgs instance + overlays
|   +-- fmt.nix              # treefmt-nix formatting (15+ tools)
|-- base/                    # System & HM foundation
|   |-- console/default.nix  # Shell/console setup
|   |-- system/default.nix   # stateVersion
|   |-- time/default.nix     # Timezone
|   |-- disko.nix            # Declarative disk partitioning
|   |-- facter.nix           # Hardware detection
|   |-- home.nix             # HM base settings
|   |-- i18n.nix             # Internationalization
|   +-- nix.nix              # Nix daemon config (dual-register)
|-- shell/                   # Shell tools (all -> homeManager.shell)
|   |-- zsh.nix, starship.nix, fzf.nix, bat.nix, eza.nix, fd.nix,
|   +-- yazi.nix, zoxide.nix, lstr.nix, nix-your-shell.nix, archive.nix
|-- dev/                     # Dev tools (all -> homeManager.dev)
|   |-- git.nix, direnv.nix, editors.nix, devenv.nix, just.nix,
|   |-- ansible.nix, hyperfine.nix, ripgrep.nix
|   +-- languages/           # Language toolchains
|       +-- rust.nix, go.nix, javascript.nix, nix.nix, python.nix
|-- desktop/                 # Desktop environment (dual-register: nixos.* + homeManager.desktop)
|   +-- niri.nix, waybar.nix, alacritty.nix, audio.nix, bluetooth.nix,
|       fcitx5.nix, fonts.nix, fuzzel.nix, media.nix, nvidia.nix,
|       power.nix, screenshot.nix, swayidle.nix, swaylock.nix, swww.nix,
|       theming.nix, wired-notify.nix, wlogout.nix, browser.nix
|-- wsl/default.nix          # WSL config (dual-register: nixos.wsl + homeManager.wsl)
+-- users/loss/default.nix   # User config (metadata + nixos user + HM user)
```

---

## Organization Rules

### When to create a new file vs. extend existing

| Situation | Action |
|-----------|--------|
| New independent tool/program | Create new file: `modules/<category>/<tool>.nix` |
| Extension of existing feature | Edit existing file |
| New language toolchain | Create `modules/dev/languages/<lang>.nix` |
| Feature needing system + user config | Create dual-register file in appropriate category |

### When to use subdirectories

Use `<name>/default.nix` pattern (instead of `<name>.nix`) when:
- The module needs auxiliary data files (e.g., `facter.json`)
- The module is large enough to benefit from splitting (rare in this project)
- Multiple related files compose a single feature

**Current examples**: `console/default.nix`, `system/default.nix`, `time/default.nix`, `wsl/default.nix`, `users/loss/default.nix`

---

## Naming Conventions

| Element | Convention | Examples |
|---------|-----------|----------|
| Module file | `<tool-or-feature>.nix` | `git.nix`, `audio.nix`, `rust.nix` |
| Subdirectory module | `<feature>/default.nix` | `console/default.nix` |
| Language toolchain | `languages/<lang>.nix` | `languages/rust.nix` |
| Category directory | lowercase, singular noun | `shell/`, `dev/`, `desktop/` |

---

## Forbidden Patterns

- **Never** create a manual import list in `flake.nix` — `import-tree` handles this
- **Never** put host-specific config in `modules/` — that belongs in `hosts/`
- **Never** modify `modules/flake-parts/` without explicit review approval
- **Never** create deeply nested directories (max 2 levels: `modules/dev/languages/`)

---

## Examples of Well-Organized Modules

| Module | Why it's exemplary |
|--------|-------------------|
| `modules/base/i18n.nix` | Simplest pattern — 7 lines, pure config |
| `modules/shell/fzf.nix` | Clean single-namespace HM module with pkgs |
| `modules/wsl/default.nix` | Dual-register pattern (nixos + HM in one file) |
| `modules/dev/languages/rust.nix` | Proper overlay injection via inputs |
| `modules/dev/git.nix` | Cross-layer reference using topLevel pattern |
