# Batteries Reference

Den ships reusable aspect providers under `den.provides` (aliased `den._`). Each battery contributes NixOS/Darwin/home-manager modules to hosts and users that include them via `den.ctx`.

## User management

### `den._.define-user`

Creates OS-level user accounts (`users.users.<name>`) with `isNormalUser` and `home` directory. Works on NixOS/Darwin/WSL/HomeManager.

### `den._.primary-user`

Marks a user as the primary user (admin level) of a host. Works in NixOS/Darwin/WSL.

### `den._.host-name`

Automatically sets the host's name to the one defined in `den.hosts.<arch>.hostName`. Works on NixOS/Darwin/WSL.

### `den._.user`

A `user` class automatically enabled by Den to forward settings into the host's `users.users.<name>`. Forwards work into NixOS/Darwin classes.

### `den._.shell`

Sets the user's login shell (`users.users.<name>.shell`), enabling the shell at host level and the home-manager `programs.<shell>.enable`.

## Composition

### `den._.mutual-provider`

Allows the user and host to contribute configuration to each other via `.provides.<name>`.

### `den._.forward`

Forwards aspect configuration from one aspect to another. Used for separation of concerns. See Cross-context forwarding in Aspects reference.

```nix
den.aspects.foo.includes = [
  (den._.forward {
    fromAspect = den.aspects.bar;
    fromClass = c: "nixos";
    intoClass = c: "homeManager";
  })
];
```

### `den._.import-tree`

Provides `inputs.import-tree` helpers to import trees of non-dendritic legacy modules (directories containing only nixos modules, etc.).

## System

### `den._.tty-autologin`

Configures TTY auto-login for the primary user via `services.getty.autologinUser`.

### `den._.wsl`

WSL-specific activation. Enables `den.ctx.wsl-host` when `host.wsl.enable = true` and includes NixOS-WSL module.

## Flake-parts batteries

These only work when the module system is flake-parts'.

### `den._.inputs'`

Exposes `inputs'` (system-qualified inputs) into aspect modules. Source: `provides/flake-parts/inputs.nix`

### `den._.self'`

Exposes `self'` (system-qualified self outputs) into aspect modules. Source: `provides/flake-parts/self.nix`

## Home-manager batteries

### `den._.hm-host`

Defines `den.ctx.hm-host` which activates when at least one user has `homeManager` classes. Use to set `home-manager.useGlobalPkgs` and `useUserPackages`.

### `den._.hm-os`

Merges home-manager configuration into the host OS module system. Bridges `home-manager.users.<name>` with the user's `homeManager` class.

### `den._.hm-module`

Imports the appropriate home-manager module (`nixos` or `darwin`).

### `den._.hjem`

Integrates hjem as an alternative to home-manager. Imports hjem's NixOS/Darwin module.

### `den._.hjem-user`

Merges hjem user configuration into the host. Sets `hjem.users.<name>` from the user's `hjem` class.

### `den._.maid`

Integrates maid as an alternative home management system.

### `den._.maid-user`

Merges maid configuration into the host OS `users.users.<name>.maid` for each user's `maid` class.

## Package management

### `den._.unfree`

Allows unfree packages by name via `nixpkgs.config.allowUnfreePredicate`.
