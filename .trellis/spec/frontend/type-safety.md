# Type Safety & Option Definitions

> How the Nix type system is used in this project.

---

## Overview

This project takes a **minimal option definition** approach. Unlike traditional NixOS modules that define extensive `options` blocks, this project relies on:
- The NixOS module system's built-in options (from nixpkgs)
- Home Manager's built-in options
- Only a few custom options at the flake-parts infrastructure level

---

## Custom Options in This Project

The only custom option definitions are in the flake-parts infrastructure layer:

### flake.meta (Project Metadata)

Defined in `modules/flake-parts/flake.nix`:

```nix
options.flake.meta = lib.mkOption {
  type = with lib.types; lazyAttrsOf anything;
};
```

This is intentionally loosely typed (`lazyAttrsOf anything`) to allow flexible metadata storage.

### flake.modules.* (Module Namespaces)

Defined in `modules/flake-parts/flake-parts.nix` — enables the `flake.modules.nixos.*` and `flake.modules.homeManager.*` namespace system.

---

## When to Use lib.mk* Functions

### lib.mkDefault — Overridable Defaults

Use when setting a value that hosts or other modules might want to override:

```nix
# modules/base/nix.nix
nix.settings.experimental-features = lib.mkDefault ["nix-command" "flakes"];
```

### lib.mkForce — Non-Overridable Values

Use sparingly, only when a value **must not** be overridden:

```nix
# Almost never needed in regular modules
security.sudo.enable = lib.mkForce true;
```

### lib.mkMerge — Combining Multiple Config Blocks

Use when a module needs to set the same attribute from multiple conditional blocks:

```nix
# modules/shell/zsh.nix
programs.zsh.initContent = lib.mkMerge [
  (lib.mkOrder 550 ''
    # Early init
  '')
  (lib.mkOrder 1100 ''
    # Late init
  '')
];
```

### lib.mkOrder / lib.mkBefore / lib.mkAfter — Ordering

Use for list/string merging where order matters:

```nix
# modules/wsl/default.nix
programs.zsh.initContent = lib.mkAfter ''
  # WSL-specific init (runs after other initContent)
'';
```

---

## Built-in Options Reference

Instead of defining custom options, modules use existing NixOS and HM options:

### NixOS Common Options

```nix
# System packages
environment.systemPackages = [pkgs.git];

# Services
services.pipewire.enable = true;

# Security
security.pam.services.swaylock = {};

# Networking
networking.hostName = "my-host";

# Hardware
hardware.graphics.enable = true;
```

### Home Manager Common Options

```nix
# Programs
programs.git.enable = true;
programs.zsh.enable = true;

# Packages
home.packages = [pkgs.ripgrep];

# Files
home.file.".config/foo".text = "bar";
xdg.configFile."foo/config".source = ./config;

# Environment
home.sessionVariables.EDITOR = "nvim";
```

---

## Type Patterns for This Project

### Attribute Set Construction

```nix
# Use // for merging attribute sets
settings = defaultSettings // {
  extra = "value";
};

# Use inherit for pulling names from scope
{ inherit pkgs lib; }
# Equivalent to: { pkgs = pkgs; lib = lib; }

# Use inherit from for pulling from attrsets
{ inherit (topLevel.config.flake.meta.users.loss) name email; }
```

### Conditional Configuration

```nix
# Use lib.mkIf for conditional blocks (rare in this project)
lib.mkIf config.programs.zsh.enable {
  programs.starship.enableZshIntegration = true;
}

# Use lib.optional / lib.optionals for conditional list items
home.packages = lib.optionals isDarwin [pkgs.darwin-specific];
```

---

## Forbidden Patterns

| Pattern | Why It's Forbidden | Alternative |
|---------|-------------------|-------------|
| Defining options in regular modules | Adds unnecessary complexity | Use existing NixOS/HM options |
| Using `types.anything` in regular modules | Too loose, hides errors | Only used in flake.meta infrastructure |
| Complex nested option types | Over-engineering | Keep modules as simple config assignments |
| `assert` statements for validation | Breaks evaluation silently | Use `lib.mkIf` or let the module system handle it |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Creating `options.myModule.enable` in a regular module | Just set the config directly — this isn't a reusable library |
| Using `lib.mkForce` when `lib.mkDefault` would work | `mkForce` prevents overrides. Use `mkDefault` for flexible defaults |
| Not using `inherit` when pulling multiple names | `inherit (scope) a b c;` is cleaner than `a = scope.a; b = scope.b;` |
| Forgetting `lib.mkMerge` when setting same attr conditionally | Without merge, last assignment wins silently |
