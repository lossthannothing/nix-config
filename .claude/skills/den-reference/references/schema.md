# Schema Reference

## `den.schema` — Base Modules

Each of `host`, `user`, `home` configuration objects have freeform-types — you can assign any attribute as metadata. Schema base modules define shared options across all entities of a kind.

| Option | Type | Description |
|--------|------|-------------|
| `den.schema.conf` | `deferredModule` | Applied to host, user, and home |
| `den.schema.host` | `deferredModule` | Applied to all hosts (imports `conf`) |
| `den.schema.user` | `deferredModule` | Applied to all users (imports `conf`) |
| `den.schema.home` | `deferredModule` | Applied to all homes (imports `conf`) |

Example — define a shared option and set defaults:

```nix
den.schema.host = { host, lib, ... }: {
  options.hardened = lib.mkEnableOption "Is it secure";
  config.hardened = lib.mkDefault true;
};

den.schema.user = { user, lib, ... }: {
  config.classes = lib.mkDefault [ "homeManager" ];
};
```

## `den.hosts` — Host Declarations

Type: `attrsOf (attrsOf systemType)`, keyed by system string (e.g. `"x86_64-linux"`).

```nix
den.hosts.x86_64-linux.myhost = {
  users.vic = {};
};
```

### Host options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `name` | `str` | attr name | Configuration name |
| `hostName` | `str` | `name` | Network hostname |
| `system` | `str` | parent key | Platform (e.g. `x86_64-linux`) |
| `class` | `str` | auto | `"nixos"` or `"darwin"` based on system |
| `aspect` | `str` | `name` | Main aspect name for this host |
| `description` | `str` | auto | `class.hostName@system` |
| `resolved` | `raw` | auto | Resolved aspect from context pipeline |
| `users` | `attrsOf userType` | `{}` | User accounts on this host |
| `instantiate` | `raw` | auto | OS builder function |
| `intoAttr` | `listOf str` | auto | Flake output path |
| `*` | schema options | | Free-form attributes |

### `instantiate` defaults

| Class | Default |
|-------|---------|
| `nixos` | `inputs.nixpkgs.lib.nixosSystem` |
| `darwin` | `inputs.darwin.lib.darwinSystem` |
| `systemManager` | `inputs.system-manager.lib.makeSystemConfig` |

### `intoAttr` defaults

| Class | Default |
|-------|---------|
| `nixos` | `[ "nixosConfigurations" name ]` |
| `darwin` | `[ "darwinConfigurations" name ]` |
| `systemManager` | `[ "systemConfigs" name ]` |

## `den.hosts...users` — User Entries

Type: `attrsOf userType`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `name` | `str` | attr name | User configuration name |
| `userName` | `str` | `name` | System account name |
| `classes` | `listOf str` | `[ "homeManager" ]` | Home management classes |
| `aspect` | `str` | `name` | Main aspect name |
| `resolved` | `raw` | auto | Resolved aspect from context pipeline |
| `*` | schema options | | Free-form attributes |

## `den.homes` — Standalone Home Configurations

Type: `attrsOf (attrsOf homeSystemType)`, keyed by system string.

```nix
den.homes.x86_64-linux.vic = {};
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `name` | `str` | attr name | Home configuration name |
| `userName` | `str` | `name` | User account name |
| `system` | `str` | parent key | Platform system |
| `class` | `str` | `"homeManager"` | Home management class |
| `aspect` | `str` | `name` | Main aspect name |
| `description` | `str` | auto | `home.userName@system` |
| `pkgs` | `raw` | `inputs.nixpkgs.legacyPackages.$sys` | Nixpkgs instance |
| `instantiate` | `raw` | `inputs.home-manager.lib.homeManagerConfiguration` | Builder |
| `resolved` | `raw` | auto | Resolved aspect from context pipeline |
| `intoAttr` | `listOf str` | `[ "homeConfigurations" name ]` | Output path |
| `*` | schema options | | Free-form attributes |

## `resolved` attribute

Every entity (host, user, home) has a `resolved` attribute — the aspect produced by running the entity through its context pipeline (`den.ctx.${kind}`). Auto-derived, used internally by `mainModule` to produce the entity's final configuration.

To control which aspects are included during resolution, set `meta.adapter` on a context node:

```nix
den.ctx.host.meta.adapter = inherited: den.lib.aspects.adapters.filter (a: a.name != "unwanted") inherited;
```
