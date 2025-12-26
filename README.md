# nix-config

Personal NixOS and Home Manager configuration, inspired by [drupol/infra](https://github.com/drupol/infra) modular architecture pattern.

## Architecture Overview

This configuration uses a **decentralized module system** powered by `flake-parts` and `import-tree`:

- **flake.nix** - Entry point, defines inputs and core mechanisms
- **modules/** - Capability layer, auto-scanned functional modules
- **hosts/** - Instance layer, self-registering host configurations

### Key Principles

1. **Decentralized**: `flake.nix` provides mechanisms, not hardcoded host lists
2. **Distributed Registration**: Each host self-registers in its own file via `flake.modules`
3. **Co-location**: System and user configurations unified per feature

### How It Works

```nix
# Auto-scan directories
(inputs.import-tree ./modules)  # Scan all feature modules
(inputs.import-tree ./hosts)    # Scan all host configs

# Modules register themselves
flake.modules.nixos.<name> = { ... };
flake.modules.homeManager.<name> = { ... };

# Hosts self-register and compose modules
flake.modules.nixos."hosts/<hostname>" = {
  imports = [ config.flake.modules.nixos.base /* ... */ ];
};
```

## Directory Structure

```
nix-config/
├── flake.nix              # Flake entry point
├── flake.lock             # Dependency lock file
├── apply_ref.sh           # Reference deployment script
├── modules/               # Feature modules (auto-scanned)
│   ├── base/              # Base system + user config
│   ├── dev/               # Development tools
│   │   └── languages/     # Language toolchains (Rust, Nix, etc.)
│   ├── shell/             # Shell configurations (Zsh, Bash, etc.)
│   ├── desktop/           # Desktop environment
│   ├── users/             # User-specific configs
│   └── flake-parts/       # Flake-parts generators
│       ├── host-machines.nix  # Auto-generates nixosConfigurations
│       └── nixpkgs.nix        # Nixpkgs configuration
└── hosts/                 # Host definitions (auto-scanned)
    └── nixos-wsl/         # WSL host configuration
        └── default.nix    # Self-registering host definition
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

# For other systems, use the interactive script
./apply_ref.sh
```

### Common Commands

```bash
# Check flake configuration
nix flake check

# Update dependencies
nix flake update

# Format code
nix fmt

# Show available systems
nix flake show

# Build without activating
nixos-rebuild build --flake .#nixos-wsl

# Test configuration
nixos-rebuild dry-run --flake .#nixos-wsl
```

## Configuration Guide

### Adding a New Package

**System-level** (edit `modules/base/system/default.nix`):
```nix
environment.systemPackages = with pkgs; [
  your-package
];
```

**User-level** (edit `modules/base/home/default.nix`):
```nix
home.packages = with pkgs; [
  your-package
];
```

### Creating a New Module

1. Create `modules/category/default.nix`:
```nix
{
  flake.modules = {
    # System-level config
    nixos.my-module = { pkgs, ... }: {
      environment.systemPackages = [ pkgs.my-package ];
      services.my-service.enable = true;
    };

    # User-level config
    homeManager.my-module = { pkgs, ... }: {
      programs.my-program.enable = true;
      home.packages = [ pkgs.my-tool ];
    };
  };
}
```

2. Reference in host config (`hosts/*/default.nix`):
```nix
imports = with config.flake.modules.nixos; [
  # ... existing imports
  my-module
];

home-manager.users.loss = {
  imports = with config.flake.modules.homeManager; [
    # ... existing imports
    my-module
  ];
};
```

### Adding a New Host

1. Create `hosts/hostname/default.nix`:
```nix
{ config, inputs, ... }: {
  flake.modules.nixos."hosts/hostname" = {
    imports = [
      # Platform-specific base (e.g., hardware config)
      # ...

      # Compose modules
      config.flake.modules.nixos.base
      config.flake.modules.nixos.dev
    ] ++ [
      {
        home-manager.users.username = {
          imports = with config.flake.modules.homeManager; [
            base
            dev
          ];
        };
      }
    ];
  };
}
```

2. Build the system:
```bash
nixos-rebuild switch --flake .#hostname
```

## Module System

### Module Types

- **nixos modules**: System-level configuration (`flake.modules.nixos.*`)
- **homeManager modules**: User-level configuration (`flake.modules.homeManager.*`)
- **Co-located modules**: Single file defining both system and user configs

### Auto-scanning

All `.nix` files in `modules/` and `hosts/` are automatically imported via `import-tree`. No manual registration needed.

### Module Registry

Modules register themselves to the global `flake.modules` attribute set:

```nix
{
  flake.modules.nixos.my-module = { ... };
  flake.modules.homeManager.my-module = { ... };
}
```

Host configs reference these modules via `config.flake.modules.*`.

## Technology Stack

- **[Nix Flakes](https://nixos.wiki/wiki/Flakes)** - Reproducible builds
- **[flake-parts](https://flake.parts/)** - Modular flake management
- **[import-tree](https://github.com/vic/import-tree)** - Auto-scan directories
- **[Home Manager](https://github.com/nix-community/home-manager)** - User environment management
- **[NixOS-WSL](https://github.com/nix-community/NixOS-WSL)** - WSL integration
- **[rust-overlay](https://github.com/oxalica/rust-overlay)** - Rust toolchain
- **[treefmt-nix](https://github.com/numtide/treefmt-nix)** - Code formatting

## Platform Support

Current configurations:

- **NixOS-WSL** (x86_64-linux) - Primary development environment
- Extensible to other platforms (NixOS, nix-darwin)

## Project Philosophy

This configuration follows these principles:

1. **Modularity**: Each module is self-contained and reusable
2. **Composability**: Combine modules freely without coupling
3. **Simplicity**: Clear structure, minimal abstraction
4. **Maintainability**: Easy to understand and modify
5. **Best Practices**: Follow NixOS and Nix community standards

## Inspiration

This project is inspired by:

- **[drupol/infra](https://github.com/drupol/infra)** - Decentralized module architecture
- **[Refactoring my infrastructure-as-code configurations](https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/)** - Design philosophy

## Documentation

- **[AGENTS.md](./AGENTS.md)** - AI coding assistant instructions
- **[CLAUDE.md](./CLAUDE.md)** - Claude-specific project context
- **[NixOS Manual](https://nixos.org/manual/nixos/stable/)** - Official NixOS documentation
- **[Home Manager Manual](https://nix-community.github.io/home-manager/)** - Home Manager options
- **[Flake-parts Docs](https://flake.parts/)** - Flake-parts module system

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
