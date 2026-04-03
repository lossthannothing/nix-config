# Module Patterns

> The 5 standard patterns for writing aspects in the vic/den framework.

---

## Overview

Every aspect in this project follows one of 5 patterns. Choose the simplest pattern that meets your needs.

**Pattern selection flow:**
1. Global defaults? -> **Pattern A** (den.default)
2. User definition? -> **Pattern B** (den.aspects.user)
3. Reusable aspect? -> **Pattern C** (namespace.aspect)
4. Sub-aspect (hierarchical)? -> **Pattern D** (namespace.parent._.child)
5. Host definition? -> **Pattern E** (den.hosts + den.aspects.host)

---

## Pattern A: Global Defaults

**When**: Configuration that applies to ALL hosts and users.

```nix
# modules/default.nix
{ inputs, __findFile, ... }: {
  den.default = {
    includes = [
      <den/home-manager>
      <den/define-user>
    ];

    nixos = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
    };

    homeManager = { ... }: {
      programs.home-manager.enable = true;
    };
  };
}
```

**Key traits:**
- Registered to `den.default`
- Uses `includes` to pull in den framework modules
- Defines both `nixos` and `homeManager` sections
- Applies to all hosts automatically

---

## Pattern B: User Aspect

**When**: Defining a user account and their default aspects.

```nix
# modules/loss.nix
{ __findFile, ... }: {
  den.aspects.loss = {
    includes = [
      <den/primary-user>
      <loss/shell>
      <loss/dev>
    ];

    nixos = {
      users.users.loss = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
      };
    };

    homeManager = {
      home = {
        username = "loss";
        homeDirectory = "/home/loss";
      };
    };
  };
}
```

**Key traits:**
- Registered to `den.aspects.<username>`
- Uses `<den/primary-user>` for common user setup
- Includes user-specific aspects via `<namespace/aspect>`
- **Never** includes host binding here — that goes in host config

---

## Pattern C: Reusable Aspect

**When**: Creating a reusable configuration module.

```nix
# modules/shell.nix
{ loss.shell.homeManager = { pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
};}
```

**Key traits:**
- Registered to custom namespace (e.g., `loss.shell`)
- Can be `nixos`, `homeManager`, or both
- Referenced via `<namespace/aspect>` in includes

---

## Pattern D: Sub-Aspect (Hierarchical)

**When**: Creating a child aspect under a parent (e.g., language under dev).

```nix
# modules/dev/rust.nix
{ inputs, ... }: {
  loss.dev._.rust = {
    nixos = {
      nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
    };

    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.rust-bin.stable.latest.default ];
    };
  };
}
```

**Key traits:**
- Uses `._.` pattern: `namespace.parent._.child`
- `._` is the `provides` alias in den/flake-aspects
- Referenced as `parent._.child` in includes

**Usage in host:**
```nix
includes = with loss; [
  dev           # Parent aspect
  dev._.rust    # Sub-aspect
];
```

---

## Pattern E: Host Definition

**When**: Defining a host and composing its aspects.

```nix
# modules/hosts/nixos-wsl/default.nix
{ loss, ... }: {
  # Host registration
  den.hosts.x86_64-linux.nixos-wsl = {};

  # Host aspect composition
  den.aspects.nixos-wsl = {
    includes = with loss; [
      wsl
      shell
      dev
      dev._.rust
      dev._.javascript
      dev._.go
      dev._.python
      dev._.nix
    ];

    nixos = { ... }: {
      wsl.defaultUser = "loss";
      wsl.docker-desktop.enable = true;
    };
  };
}
```

**Key traits:**
- Registers host via `den.hosts.<arch>.<hostname>`
- Composes aspects via `includes`
- Host-specific overrides go in `nixos`/`homeManager` sections
- Uses `with loss;` for cleaner aspect references

---

## Pattern Selection Decision Tree

```
Is this global configuration (applies to all hosts)?
  Yes -> Pattern A (den.default)

Is this a user account definition?
  Yes -> Pattern B (den.aspects.user)

Is this a host definition?
  Yes -> Pattern E (den.hosts + den.aspects.host)

Is this a child of another aspect?
  Yes -> Pattern D (namespace.parent._.child)

Otherwise -> Pattern C (namespace.aspect)
```

---

## Shared Constants Pattern

**When**: Configuration values are used in multiple places.

```nix
# modules/default.nix
{ inputs, __findFile, ... }: let
  stateVersion = "25.11";

  substituters = [
    "https://nix-community.cachix.org"
    "https://cache.nixos.org/"
  ];

  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
in {
  den.default = {
    nixos = { ... }: {
      system.stateVersion = stateVersion;
      nix.settings = { inherit substituters trusted-public-keys; };
    };

    homeManager = { ... }: {
      home.stateVersion = stateVersion;
      nix.settings = { inherit substituters trusted-public-keys; };
    };
  };
}
```

**Key traits:**
- Use `let` bindings at file top
- Reference via `inherit` or direct variable use
- Single source of truth for repeated values

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Using `imports` instead of `includes` | Aspects use `includes` for composition |
| Putting host binding in user module | Host binding belongs in `modules/hosts/*/default.nix` |
| Using `loss.dev.rust` instead of `loss.dev._.rust` | Sub-aspects must use `._.` pattern |
| Duplicating values across nixos/homeManager | Use `let` bindings and `inherit` |
| Forgetting `{ inputs, ... }:` when using flake inputs | Add `inputs` parameter at file top |
| Using `__findFile` without importing den module | `__findFile` is set in `den.nix` |

---

## Aspect Composition Rules

1. **Parent before child**: Include parent aspect before sub-aspects
2. **Order doesn't matter for siblings**: `dev._.rust` and `dev._.javascript` can be in any order
3. **Use `with namespace;`**: Cleaner than repeating `namespace.` prefix
4. **Angle-bracket imports**: Use `<namespace/aspect>` not relative paths
