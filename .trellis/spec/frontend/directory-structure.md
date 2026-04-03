# Module Directory Structure

> How Nix modules are organized in the vic/den framework.

---

## Overview

All configurations live in `modules/`. The `import-tree` flake input automatically discovers every `.nix` file. Each file registers aspects to the `den.*` or custom namespaces (e.g., `loss.*`).

---

## Directory Layout

```
modules/
├── den.nix                  # Framework init + "loss" namespace registration
├── default.nix              # den.default — global defaults (nix, locale, HM)
├── loss.nix                 # den.aspects.loss — user "loss" definition
├── shell.nix                # loss.shell — shell tools (zsh, starship, etc.)
├── dev.nix                  # loss.dev — dev tools (git, direnv, etc.)
├── wsl.nix                  # loss.wsl — WSL platform aspect
├── nixpkgs.nix              # perSystem pkgs + flake overlays
├── formatter.nix            # treefmt-nix configuration
├── dev/                     # Language-specific sub-aspects
│   ├── rust.nix             # loss.dev._.rust
│   ├── javascript.nix       # loss.dev._.javascript
│   ├── go.nix               # loss.dev._.go
│   ├── python.nix           # loss.dev._.python
│   └── nix.nix              # loss.dev._.nix
└── hosts/                   # Host definitions
    └── nixos-wsl/
        └── default.nix      # Host + aspect composition
```

---

## File Responsibilities

| File | Namespace | Responsibility |
|------|-----------|----------------|
| `den.nix` | — | Load den flakeModule, register `loss` namespace, setup `__findFile` |
| `default.nix` | `den.default` | Nix daemon, locale, timezone, HM integration, substituters |
| `loss.nix` | `den.aspects.loss` | User account, home directory, aspect includes |
| `shell.nix` | `loss.shell` | Shell tools (zsh, starship, bat, eza, fzf, etc.) |
| `dev.nix` | `loss.dev` | Dev tools (git, direnv, editors, ripgrep) |
| `wsl.nix` | `loss.wsl` | WSL system config + user aliases |
| `dev/*.nix` | `loss.dev._.*` | Language-specific environments |
| `hosts/*/default.nix` | `den.hosts.*` + `den.aspects.*` | Host definition + aspect composition |

---

## Organization Rules

### When to create a new file

| Situation | Action |
|-----------|--------|
| New user | Create `modules/<username>.nix` |
| New platform aspect | Create `modules/<platform>.nix` (e.g., `wsl.nix`) |
| New language environment | Create `modules/dev/<lang>.nix` |
| New host | Create `modules/hosts/<hostname>/default.nix` |

### When to use subdirectories

Use `<name>/default.nix` pattern when:
- The module needs auxiliary data files
- The aspect is complex enough to benefit from splitting

### Sub-aspect pattern

For hierarchical aspects (e.g., language environments under dev):

```nix
# modules/dev/rust.nix
loss.dev._.rust = { ... };  # Note the `._.` pattern
```

This is accessed via:
```nix
# modules/hosts/nixos-wsl/default.nix
includes = with loss; [
  dev
  dev._.rust      # Sub-aspect reference
];
```

---

## Naming Conventions

| Element | Convention | Examples |
|---------|-----------|----------|
| User aspect file | `<username>.nix` | `loss.nix` |
| Platform aspect | `<platform>.nix` | `wsl.nix` |
| Sub-aspect directory | `<parent>/` | `dev/` |
| Sub-aspect file | `<parent>/<child>.nix` | `dev/rust.nix` |
| Host directory | `hosts/<hostname>/` | `hosts/nixos-wsl/` |

---

## Forbidden Patterns

- **Never** put host binding (`den.hosts.*.users.*`) in user modules — it belongs in host config
- **Never** duplicate configuration values — use `let` bindings
- **Never** hardcode user-specific values in shared modules
- **Never** create deeply nested directories (max 2 levels)

---

## Examples

### Aspect with shared constants

```nix
# modules/wsl.nix
{ inputs, ... }: let
  winUser = "Lossilklauralin";  # Single source of truth
in {
  loss.wsl = {
    homeManager = { ... }: {
      home.sessionVariables.WIN_USER = winUser;
    };
  };
}
```

### Sub-aspect with overlay

```nix
# modules/dev/rust.nix
{ inputs, ... }: {
  loss.dev._.rust = {
    nixos.nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.rust-bin.stable.latest.default ];
    };
  };
}
```

### Host composition

```nix
# modules/hosts/nixos-wsl/default.nix
{ loss, ... }: {
  den.hosts.x86_64-linux.nixos-wsl = {};

  den.aspects.nixos-wsl = {
    includes = with loss; [
      wsl
      shell
      dev
      dev._.rust
      dev._.javascript
    ];

    nixos = { ... }: {
      wsl.defaultUser = "loss";
    };
  };
}
```
