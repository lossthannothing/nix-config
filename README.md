# nix-config

Personal NixOS and Home Manager configuration, inspired by [drupol/infra](https://github.com/drupol/infra) modular architecture pattern.

## Architecture Overview

This configuration uses a **decentralized module system** powered by `flake-parts` and `import-tree`:

```
┌─────────────────────────────────────────────────────────┐
│  flake.nix (Mechanism Layer)                            │
│  ┌─────────────────────────────────────────────────┐  │
│  │  inputs: All external dependencies (centralized)│  │
│  │  import-tree auto-scans                         │  │
│  │  - ./modules/*  → flake.modules                │  │
│  │  - ./hosts/*    → nixosConfigurations          │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  modules/ (Capability Layer)                            │
│  ┌─────────────────────────────────────────────────┐  │
│  │  flake.modules.nixos.*        (system configs) │  │
│  │  flake.modules.homeManager.*  (user configs)   │  │
│  └─────────────────────────────────────────────────┘  │
│           ↓                    ↓                     │
│  dev/, shell/, base/, desktop/, wsl/, users/        │
│  (auto-merged to aggregate modules)                  │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  hosts/ (Instance Layer)                                │
│  ┌─────────────────────────────────────────────────┐  │
│  │  nixos-wsl/      → NixOS-WSL                │  │
│  │  nixos-desktop/  → NixOS Desktop (Niri+NVIDIA)│  │
│  │  nixos-vm/       → NixOS VM (light desktop)  │  │
│  │  fedora-wsl/     → Fedora-WSL (HM only)      │  │
│  └─────────────────────────────────────────────────┘  │
│  Compose capabilities from modules via imports          │
└─────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Decentralized**: `flake.nix` provides mechanisms, not hardcoded host lists
2. **Distributed Registration**: Each host self-registers via `flake.modules`
3. **Co-location**: System and user configurations unified per feature
4. **Auto-merge**: `dev/` and `shell/` modules automatically aggregate

### Module Auto-Merge Rules

| Directory | Module Path | Description |
|-----------|-------------|-------------|
| `modules/dev/*.nix` | `homeManager.dev` | Dev tools (auto-merged, 14 files) |
| `modules/shell/*.nix` | `homeManager.shell` | Shell tools (auto-merged, 11 files) |
| `modules/desktop/*.nix` | `homeManager.desktop` | Desktop HM configs (auto-merged, 14+ files) |

**Important**: When adding tools to `dev/` or `shell/`, just create the file — no need to modify host configs!

## Technology Stack

| Technology | Role | Status |
|------------|------|--------|
| Nix Flakes | Reproducible, declarative builds | ✅ Core |
| flake-parts | Modular framework with open module options | ✅ Core |
| import-tree | Auto-scan `modules/` and `hosts/` | ✅ Core |
| Home Manager | User-level package and config management | ✅ Core |
| nixos-facter | Hardware detection, replaces hardware-configuration.nix | ✅ desktop |
| disko | Declarative disk partitioning, auto-generates fileSystems | ✅ Core |
| treefmt-nix | Multi-language formatting (alejandra/deadnix/statix/etc.) | ✅ |
| Catppuccin | Mocha theme system via catppuccin/nix | ✅ desktop |
| Niri | Scrollable-tiling Wayland compositor | ✅ desktop |
| NixOS-WSL | NixOS on WSL2 | ✅ wsl |
| rust-overlay | Rust toolchain management | ✅ |
| nixos-anywhere | Remote NixOS installation via SSH | ✅ deployment |

## Directory Structure

```
nix-config/
├── flake.nix              # Flake entry point
├── flake.lock             # Dependency lock file
├── CLAUDE.md              # Claude AI assistant context
├── README.md              # This file
├── scripts/               # Utility scripts
│   ├── deploy.sh         # Live USB (disko) & remote (nixos-anywhere) deployment
│   ├── nix-proxy.sh      # Nix proxy helper
│   ├── proxy-wrapper.sh  # Proxy wrapper for network operations
│   └── set-proxy.sh      # Proxy environment setup
├── modules/               # Feature modules (auto-scanned)
│   ├── base/              # Base system + user config
│   │   ├── console/       # Console settings
│   │   ├── system/        # System packages
│   │   ├── time/          # Timezone & locale
│   │   ├── disko.nix      # Declarative disk partitioning
│   │   ├── facter.nix     # nixos-facter integration
│   │   ├── home.nix       # Home Manager base config
│   │   ├── i18n.nix       # Internationalization
│   │   └── nix.nix        # Nix daemon settings
│   ├── dev/               # Development tools (auto-merged)
│   │   ├── languages/     # Language toolchains
│   │   │   ├── go.nix
│   │   │   ├── javascript.nix
│   │   │   ├── nix.nix
│   │   │   ├── python.nix
│   │   │   └── rust.nix   # Rust overlay injection
│   │   ├── tools/
│   │   │   └── devenv.nix
│   │   ├── ansible.nix    # Configuration management
│   │   ├── claude.nix     # Claude Code
│   │   ├── direnv.nix     # Per-directory environments
│   │   ├── editors.nix    # Code editors
│   │   ├── git.nix        # Git configuration
│   │   ├── hyperfine.nix  # Benchmarking
│   │   ├── just.nix       # Task runner
│   │   └── ripgrep.nix    # Fast grep (rg)
│   ├── shell/             # Shell tools (auto-merged)
│   │   ├── archive.nix    # Archive handling (extract)
│   │   ├── bat.nix        # cat with syntax highlighting
│   │   ├── eza.nix        # ls with git integration
│   │   ├── fd.nix         # find replacement
│   │   ├── fzf.nix        # Fuzzy finder
│   │   ├── nix-your-shell.nix  # Nix shell integration
│   │   ├── starship.nix   # Cross-shell prompt
│   │   ├── zoxide.nix     # cd replacement (z/cdi)
│   │   └── zsh.nix        # Zsh configuration
│   ├── desktop/           # Desktop environment
│   │   ├── alacritty.nix  # Terminal emulator
│   │   ├── audio.nix      # PipeWire audio
│   │   ├── bluetooth.nix  # Bluetooth support
│   │   ├── browser.nix    # Browser configuration
│   │   ├── fcitx5.nix     # Input method (NixOS + HM)
│   │   ├── fonts.nix      # Font configuration
│   │   ├── fuzzel.nix     # Application launcher
│   │   ├── media.nix      # Media applications
│   │   ├── niri.nix       # Wayland compositor
│   │   ├── nvidia.nix     # NVIDIA drivers
│   │   ├── power.nix      # Power management
│   │   ├── screenshot.nix # Screen capture
│   │   ├── swayidle.nix   # Idle management
│   │   ├── swaylock.nix   # Screen locking (PAM)
│   │   ├── swww.nix       # Wallpaper daemon
│   │   ├── theming.nix    # Catppuccin theming
│   │   ├── waybar.nix     # Status bar
│   │   ├── wired-notify.nix  # Notification daemon
│   │   └── wlogout.nix    # Logout menu
│   ├── wsl/               # WSL unified config
│   │   └── default.nix    # nixos.wsl + homeManager.wsl
│   ├── users/             # User-specific configs
│   │   └── loss/
│   │       └── default.nix    # nixos.loss + homeManager.loss
│   └── flake-parts/       # Flake-parts generators
│       ├── flake-parts.nix
│       ├── flake.nix
│       ├── fmt.nix        # Code formatting
│       ├── host-machines.nix  # Auto-generates configurations
│       └── nixpkgs.nix        # Nixpkgs config + overlays
└── hosts/                 # Host definitions (auto-scanned)
    ├── nixos-wsl/         # NixOS-WSL
    ├── nixos-desktop/     # NixOS Desktop (Niri + NVIDIA + Catppuccin)
    ├── nixos-vm/          # NixOS VM (light desktop)
    └── fedora-wsl/        # Fedora-WSL (Home Manager only)
```

## Quick Start

### Prerequisites

- Nix 2.19+ with flakes enabled
- Git
- NixOS or NixOS-WSL

### Installation

1. Clone this repository:
```bash
git clone https://github.com/lossthannothing/nix-config.git
cd nix-config
```

2. Deploy to your system:
```bash
# For NixOS-WSL
sudo nixos-rebuild switch --flake .#nixos-wsl

# For NixOS Desktop
sudo nixos-rebuild switch --flake .#nixos-desktop

# For Home Manager only (e.g., Fedora-WSL)
home-manager switch --flake .#hosts/fedora-wsl

# For local installation via Live USB (disko)
./scripts/deploy.sh --local nixos-desktop

# For remote installation (nixos-anywhere)
./scripts/deploy.sh nixos-vm 192.168.122.100
```

### Common Commands

```bash
# Check flake configuration
nix flake check

# Format code (alejandra, deadnix, statix, etc.)
nix fmt

# Update dependencies
nix flake update

# Show available systems
nix flake show

# Build without activating
nixos-rebuild build --flake .#nixos-wsl

# Test configuration
nixos-rebuild dry-run --flake .#nixos-wsl

# Debug with nix repl
nix repl
:lf .
:p outputs.nixosConfigurations.nixos-wsl.config.services
```

## Modern Toolchain

| Traditional | Modern | Config Location |
|-------------|--------|-----------------|
| `find` | `fd` | `modules/shell/fd.nix` |
| `grep` | `rg` (ripgrep) | `modules/dev/ripgrep.nix` |
| `ls` | `eza` | `modules/shell/eza.nix` |
| `cat` | `bat` | `modules/shell/bat.nix` |
| `cd` | `z` (zoxide) | `modules/shell/zoxide.nix` |
| `tree` | `eza --tree` | `modules/shell/eza.nix` |

### Usage Examples
```bash
fd --extension nix        # Find .nix files
rg "flake.modules"        # Search text
eza --tree --level=3      # Directory tree
```

## Configuration Guide

### Module Namespace Registry

**NixOS namespaces** (require explicit import in hosts):
| Namespace | Source | Description |
|-----------|--------|-------------|
| `nixos.base` | `base/*.nix` | Multi-file auto-merge |
| `nixos.facter` | `base/facter.nix` | Hardware detection |
| `nixos.disko` | `base/disko.nix` | Declarative partitioning |
| `nixos.rust` | `dev/languages/rust.nix` | Rust overlay |
| `nixos.wsl` | `wsl/default.nix` | WSL system config |
| `nixos.loss` | `users/loss/default.nix` | User system config |
| `nixos.nvidia` | `desktop/nvidia.nix` | NVIDIA driver |
| `nixos.niri` | `desktop/niri.nix` | Wayland compositor |
| `nixos.audio` | `desktop/audio.nix` | PipeWire audio |
| `nixos.bluetooth` | `desktop/bluetooth.nix` | Bluetooth |
| `nixos.power` | `desktop/power.nix` | Power management |
| `nixos.fcitx5` | `desktop/fcitx5.nix` | Input method |
| `nixos.swaylock` | `desktop/swaylock.nix` | PAM authentication |
| `nixos.fonts` | `desktop/fonts.nix` | System fonts |

**Home Manager namespaces**:
| Namespace | Source | Description |
|-----------|--------|-------------|
| `homeManager.base` | `base/home.nix`, `base/nix.nix` | Multi-file auto-merge |
| `homeManager.shell` | `shell/*.nix` (11 files) | Auto-merged |
| `homeManager.dev` | `dev/*.nix` (14 files) | Auto-merged |
| `homeManager.desktop` | `desktop/*.nix` (14+ files) | Auto-merged |
| `homeManager.wsl` | `wsl/default.nix` | WSL user config |
| `homeManager.loss` | `users/loss/default.nix` | User HM config |

### Adding Development Tools

```nix
# Create modules/dev/<tool>.nix (single step!)

# Case 1: Has programs.<tool>.enable
{
  flake.modules.homeManager.dev = {
    programs.<tool> = {enable = true;};
  };
}

# Case 2: No Home Manager support
{
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home.packages = with pkgs; [<tool>];
  };
}
```

### Adding Shell Tools

```nix
# Create modules/shell/<tool>.nix

# Case 1: Has programs.<tool>.enable
{
  flake.modules.homeManager.shell = {
    programs.<tool> = {enable = true;};
  };
}

# Case 2: No Home Manager support
{
  flake.modules.homeManager.shell = {pkgs, ...}: {
    home.packages = with pkgs; [<tool>];
  };
}
```

### Adding Desktop Components

```nix
# Create modules/desktop/<component>.nix

# Case 1: HM config only (auto-merged to homeManager.desktop)
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    programs.<component>.enable = true;
  };
}

# Case 2: Need NixOS + HM dual registration
{
  flake.modules = {
    nixos.<component> = { /* system-level */ };
    homeManager.desktop = { /* user-level, auto-merged */ };
  };
}
# Note: NixOS side requires manual import in hosts/nixos-desktop/default.nix
```

### Adding a New Host

```nix
# 1. Create hosts/<hostname>/default.nix
# 2. Choose registration mode:
#    - Full NixOS: flake.modules.nixos."hosts/<hostname>" = {...}: { ... };
#    - HM only:    flake.modules.homeManager."hosts/<hostname>" = {...}: { ... };
# 3. Import required modules (reference existing hosts)
# 4. For hardware detection: sudo nix run nixpkgs#nixos-facter -- -o hosts/<hostname>/facter.json
# 5. host-machines.nix auto-detects "hosts/" prefix and registers configurations
```

### Hardware Detection (nixos-facter)

Replaces traditional `hardware-configuration.nix`:
- `modules/base/facter.nix`: Registers `nixos.facter` module, installs facter CLI
- `hosts/nixos-desktop/facter.json`: Hardware detection report
- Usage in host: `{hardware.facter.reportPath = ./facter.json;}`
- Generate command: `sudo nix run nixpkgs#nixos-facter -- -o hosts/<hostname>/facter.json`
- **Only for desktop/VM hosts**, WSL doesn't need it (hardware managed by Windows)

## Deployment Commands

```bash
# NixOS system deployment
sudo nixos-rebuild switch --flake .#nixos-wsl         # Deploy WSL
sudo nixos-rebuild switch --flake .#nixos-desktop      # Deploy desktop
sudo nixos-rebuild switch --flake .#nixos-vm           # Deploy VM

# Home Manager standalone deployment
home-manager switch --flake .#hosts/fedora-wsl         # Deploy independent HM

# Live USB installation (disko - declarative partitioning)
./scripts/deploy.sh --local nixos-desktop

# Remote deployment (nixos-anywhere)
./scripts/deploy.sh nixos-vm 192.168.122.100
```

## Platform Support

Current configurations:

| Host | Type | Platform | Description |
|------|------|----------|-------------|
| nixos-wsl | NixOS | x86_64-linux | Primary development environment |
| nixos-desktop | NixOS | x86_64-linux | Full desktop (Niri + NVIDIA + Catppuccin) |
| nixos-vm | NixOS | x86_64-linux | Lightweight VM for testing |
| fedora-wsl | HM only | x86_64-linux | Fedora WSL with Home Manager |

## Project Philosophy

This configuration follows these principles:

1. **Modularity**: Each module is self-contained and reusable
2. **Composability**: Combine modules freely without coupling
3. **Simplicity**: Clear structure, minimal abstraction
4. **DRY**: Auto-merge and module registry eliminate duplication
5. **Maintainability**: Easy to understand and modify
6. **Best Practices**: Follow NixOS and Nix community standards

## Documentation

- **[CLAUDE.md](./CLAUDE.md)** - Detailed project architecture and patterns (Chinese)
- **[NixOS Options](https://search.nixos.org/options)** - Official NixOS options search
- **[Nix Packages](https://search.nixos.org/packages)** - Nixpkgs package search
- **[Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)** - HM options
- **[Flake-parts](https://flake.parts/)** - Flake-parts documentation
- **[import-tree](https://github.com/vic/import-tree)** - Auto-scan utility
- **[nixos-facter](https://github.com/numtide/nixos-facter)** - Hardware detection
- **[disko](https://github.com/nix-community/disko)** - Declarative partitioning
- **[nixos-anywhere](https://github.com/nix-community/nixos-anywhere)** - Remote installation

## Inspiration

This project is inspired by:

- **[drupol/infra](https://github.com/drupol/infra)** - Decentralized module architecture
- **[Refactoring my infrastructure-as-code configurations](https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/)** - Design philosophy

## Contributing

This is a personal configuration repository. Feel free to:

- Fork and adapt to your needs
- Report issues or suggest improvements
- Share your own patterns and ideas

## License

This project is available under the MIT License. See LICENSE for details.

## Author

**loss** - [GitHub](https://github.com/lossthannothing)

---

**Note**: This configuration is tailored for personal use. Review and adapt settings before deploying to your own system.
