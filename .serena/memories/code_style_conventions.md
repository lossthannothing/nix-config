# Code Style and Conventions

## Nix Code Style
- Use `nixfmt-rfc-style` for formatting
- Follow RFC 166 style guidelines
- Use descriptive variable names
- Comment complex configurations

## File Organization
- Host-specific configs in `hosts/<hostname>/`
- Each host has `default.nix`, `<hostname>-options.nix`, and `user.nix`
- OS-specific configurations in `os/spec/`
- Home Manager modules in `home/`
- Helper functions in `lib/`

## Naming Conventions
- Host configurations: `nixos-<purpose>` (e.g., `nixos-wsl`)
- File names: kebab-case with `.nix` extension
- Variables: camelCase for Nix expressions
- Module imports: explicit and organized

## Configuration Patterns
- Use `imports = [ ... ]` for module composition
- Separate system and user configurations
- Use `specialArgs` for passing custom arguments
- Leverage `lib` functions for code reuse