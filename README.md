# nix-config

[![English](https://img.shields.io/badge/lang-English-blue.svg)](README.md) [![简体中文](https://img.shields.io/badge/lang-简体中文-red.svg)](README_CN.md)

Personal NixOS configuration built with [vic/den](https://github.com/vic/den) — a context-aware, aspect-driven framework for declarative Nix systems.

## Architecture

```
flake.nix (entry)
  └── flake-parts + import-tree
       └── modules/* (auto-scanned)
            ├── den.nix          → framework init + "loss" namespace
            ├── default.nix      → den.default (applied to all hosts/users)
            ├── loss.nix         → den.aspects.loss (user "loss")
            ├── nixpkgs.nix      → perSystem pkgs + overlays
            ├── formatter.nix    → treefmt-nix
            ├── system/          → loss.system (nix, locale, wsl)
            ├── shell/           → loss.shell (zsh, starship, bat, ...)
            ├── editors/         → loss.editors (neovim)
            ├── dev/             → loss.dev.* (go, rust, python, js, nix, tools)
            ├── profiles/        → loss.profiles.* (wsl preferences)
            └── hosts/           → den.hosts + host-specific aspects
                 └── nixos-wsl/  → WSL2 NixOS instance
```

### How It Works

Den replaces flat module lists with **aspects** — composable bundles that are context-aware. An aspect like `loss.shell._.zsh` knows whether it's configuring a NixOS host, a Home Manager user, or both.

| Concept | Example | Purpose |
|---------|---------|---------|
| `den.default` | `modules/default.nix` | Baseline config for all hosts/users |
| `den.aspects.<name>` | `den.aspects.loss`, `den.aspects.nixos-wsl` | Named config bundles |
| `den.hosts.<arch>.<host>` | `den.hosts.x86_64-linux.nixos-wsl` | Host declarations |
| `loss.*` | `loss.shell`, `loss.dev._.rust` | Custom namespace for project aspects |
| `<loss/shell>` | Angle-bracket import | Reusable aspect reference |

### Aggregation Pattern

Sub-aspects are aggregated into composite aspects via `includes`:

```nix
# modules/shell/default.nix
loss.shell = {
  includes = with loss; [
    shell._.zsh
    shell._.starship
    shell._.git
    # ... more sub-aspects
  ];
};
```

Hosts compose these aggregates:

```nix
# modules/hosts/nixos-wsl/default.nix
den.aspects.nixos-wsl = {
  includes = with loss; [
    system._.wsl
    profiles.wsl
    shell            # aggregated
    dev._.tools
    dev._.rust
    # ...
  ];
};
```

## Quick Start

### Prerequisites

- Nix 2.19+ with flakes enabled
- Git

### Deploy

```bash
# Build without activating
nixos-rebuild build --flake .#nixos-wsl

# Deploy
sudo nixos-rebuild switch --flake .#nixos-wsl

# Interactive deploy menu
./scripts/deploy.sh
```

### Common Commands

```bash
nix fmt                                        # Format (alejandra + deadnix + statix)
nix flake check                                # Validate
nix flake update                               # Update inputs
nixos-rebuild dry-run --flake .#nixos-wsl      # Test without applying
```

## Directory Structure

```
nix-config/
├── flake.nix              # Flake entry — inputs + import-tree
├── flake.lock
├── CLAUDE.md              # AI assistant context
├── modules/               # All config (auto-scanned by import-tree)
│   ├── den.nix            #   Den init + "loss" namespace registration
│   ├── default.nix        #   den.default — global baseline
│   ├── loss.nix           #   den.aspects.loss — user "loss"
│   ├── nixpkgs.nix        #   perSystem pkgs, overlays, pkgs-by-name
│   ├── formatter.nix      #   treefmt-nix multi-language formatter
│   ├── system/            #   loss.system — nix daemon, locale, wsl
│   ├── shell/             #   loss.shell — zsh, starship, git, bat, eza, ...
│   ├── editors/           #   loss.editors — neovim
│   ├── dev/               #   loss.dev.* — go, rust, python, js, nix, tools
│   ├── profiles/          #   loss.profiles.* — platform-specific prefs
│   └── hosts/             #   Host definitions + per-host aspects
│       └── nixos-wsl/     #     WSL2 NixOS
├── pkgs/by-name/          #   Custom packages (pkgs-by-name-for-flake-parts)
├── scripts/               #   Utility scripts
│   ├── deploy.sh              # Interactive deploy + disko + nixos-anywhere
│   ├── git-proxy.sh           # Git proxy wrapper
│   ├── nixdaemon-proxy.sh     # Nix daemon proxy (bare-metal/VM)
│   ├── nix-daemon-wsl-proxy.sh # Nix daemon proxy (WSL)
│   └── shell-proxy.sh         # Shell session proxy
└── .ref/                  #   Reference repos (gitignored)
```

## Configuration Guide

### Adding a Shell Tool

Create `modules/shell/<tool>.nix`:

```nix
{ loss.shell._.<tool>.homeManager = { pkgs, ... }: {
  programs.<tool>.enable = true;
}; }
```

Then add it to the aggregation in `modules/shell/default.nix`.

### Adding a Dev Toolchain

Create `modules/dev/<lang>.nix`:

```nix
{ loss.dev._.<lang>.homeManager = { pkgs, ... }: {
  home.packages = [ pkgs.<lang> ];
}; }
```

Then include it in the host's `den.aspects.<host>.includes`.

### Adding a New Host

1. Create `modules/hosts/<hostname>/default.nix`
2. Declare the host and define its aspect:

```nix
{ loss, ... }: {
  den.hosts.x86_64-linux.<hostname> = {};
  den.aspects.<hostname> = {
    includes = with loss; [
      system._.nix
      shell
      dev._.tools
    ];
    nixos = { ... }: {
      # host-specific NixOS config
    };
  };
}
```

3. Deploy: `sudo nixos-rebuild switch --flake .#<hostname>`

### Context-Aware Aspects

Aspects can inspect their context (`host`, `user`, `home`) to produce different config:

```nix
{ den, ... }: {
  den.aspects.video = den.lib.take.exactly ({ host, user }: {
    nixos.users.users.${user.userName}.extraGroups = [ "video" ];
  });
}
```

Functions requiring unavailable context parameters are silently excluded — no conditional boilerplate needed.

## Technology Stack

| Technology | Role |
|------------|------|
| [den](https://github.com/vic/den) | Context-aware aspect framework |
| [flake-parts](https://flake.parts/) | Modular flake composition |
| [import-tree](https://github.com/vic/import-tree) | Auto-scan `modules/` |
| [flake-aspects](https://github.com/vic/flake-aspects) | Aspect infrastructure |
| [Home Manager](https://github.com/nix-community/home-manager) | User-level config |
| [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) | NixOS on WSL2 |
| [treefmt-nix](https://github.com/numtide/treefmt-nix) | Multi-language formatting |
| [rust-overlay](https://github.com/oxalica/rust-overlay) | Rust toolchain |
| [pkgs-by-name](https://github.com/nix-community/pkgs-by-name-for-flake-parts) | Custom package auto-discovery |

## Platform Support

| Host | Type | Description |
|------|------|-------------|
| nixos-wsl | NixOS | WSL2 development environment |

## Proxy Scripts (WSL)

```bash
./scripts/git-proxy.sh git push              # Git via proxy
sudo ./scripts/nix-daemon-wsl-proxy.sh http  # Nix daemon proxy (WSL)
sudo ./scripts/nixdaemon-proxy.sh http       # Nix daemon proxy (bare-metal/VM)
```

## Inspiration

- **[vic/den](https://github.com/vic/den)** — Context-aware Dendritic Nix configurations
- **[The Dendritic Pattern](https://github.com/vic/dendritic)** — Nixpkgs module system pattern
- **[drupol/infra](https://github.com/drupol/infra)** — Decentralized module architecture

## License

MIT
