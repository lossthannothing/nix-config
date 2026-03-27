# Module Patterns

> The 5 standard patterns for writing Nix modules in this project.

---

## Overview

Every module in this project follows one of 5 patterns. Choose the simplest pattern that meets your needs — complexity should be added only when required.

**Pattern selection flow:**
1. Need system config only? -> **Pattern A** (pure config) or **Pattern B** (needs pkgs/lib)
2. Need both system + user config? -> **Pattern C** (dual-register)
3. Need external flake inputs? -> **Pattern D** (inputs pattern)
4. Need to read flake-level metadata? -> **Pattern E** (topLevel pattern)

---

## Pattern A: Pure Config (Simplest)

**When**: Static configuration with no package references or lib functions.

```nix
# modules/base/i18n.nix
{
  flake.modules.nixos.base = {
    i18n.defaultLocale = "zh_CN.UTF-8";
  };
}
```

**Key traits:**
- Top-level is `{}` or has no parameters
- Direct assignment to `flake.modules.<type>.<namespace> = { ... };`
- No function, no pkgs, no lib

**Real examples**: `base/i18n.nix`, `base/time/default.nix`

---

## Pattern B: Single Namespace + pkgs/lib

**When**: Need to reference packages or use lib functions.

```nix
# modules/shell/fzf.nix
{
  flake.modules.homeManager.shell = { pkgs, lib, ... }: {
    programs.fzf = {
      enable = true;
      defaultCommand = "${lib.getExe pkgs.fd} --type f";
    };
  };
}
```

**Key traits:**
- Module value is a function: `{ pkgs, lib, ... }: { ... }`
- Destructure only what you need (pkgs, lib, config, etc.)
- Top-level file is still `{}` (no flake-parts parameters needed)

**Real examples**: `shell/zsh.nix`, `shell/bat.nix`, `desktop/theming.nix`

---

## Pattern C: Dual-Register (nixos + homeManager)

**When**: A feature needs both system-level (drivers, services, PAM) and user-level (dotfiles, env vars) configuration.

```nix
# modules/desktop/fcitx5.nix
{
  flake.modules = {
    nixos.fcitx5 = { pkgs, ... }: {
      i18n.inputMethod = {
        type = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-chinese-addons
          fcitx5-rime
        ];
      };
    };
    homeManager.desktop = {
      home.sessionVariables = {
        GLFW_IM_MODULE = "ibus";
      };
    };
  };
}
```

**Key traits:**
- `flake.modules = { nixos.X = ...; homeManager.Y = ...; };`
- NixOS part handles: PAM, drivers, services, system packages
- HM part handles: dotfiles, environment variables, user programs
- NixOS and HM namespaces can differ (e.g., `nixos.fcitx5` + `homeManager.desktop`)

**Real examples**: `wsl/default.nix`, `desktop/fcitx5.nix`, `desktop/swaylock.nix`, `desktop/fonts.nix`, `base/nix.nix`

**This is the project's signature pattern** — use it whenever a feature has both system and user aspects.

---

## Pattern D: Inputs Pattern (External Flake Modules)

**When**: Need to import modules or overlays from flake inputs.

```nix
# modules/dev/languages/rust.nix
{ inputs, ... }: {
  flake.modules = {
    nixos.rust = {
      nixpkgs.overlays = [inputs.rust-overlay.overlays.default];
    };
    homeManager.dev = { pkgs, ... }: {
      home.packages = [pkgs.rust-bin.stable.latest.default];
    };
  };
}
```

**Key traits:**
- Top-level function: `{ inputs, ... }:` — this is a **flake-parts module** parameter, NOT a NixOS module parameter
- Use `inputs.<name>.nixosModules.*`, `inputs.<name>.overlays.*`, etc.
- Often combined with Pattern C (dual-register)

**Real examples**: `desktop/niri.nix`, `dev/languages/rust.nix`, `base/disko.nix`

**Critical distinction**: `{ inputs, ... }:` at file top-level = flake-parts parameter. `{ pkgs, config, ... }:` inside namespace value = NixOS/HM module parameter.

---

## Pattern E: TopLevel Pattern (Cross-Layer Reference)

**When**: Need to read flake-level configuration like `config.flake.meta`.

```nix
# modules/dev/git.nix
topLevel: {
  flake.modules.homeManager.dev = { config, ... }: {
    programs.git.settings.user = {
      inherit (topLevel.config.flake.meta.users.${config.home.username}) name;
    };
  };
}
```

**Key traits:**
- Top-level parameter explicitly named `topLevel` (not destructured)
- Access flake-level data via `topLevel.config.flake.*`
- Used when module config depends on project metadata

**Real examples**: `users/loss/default.nix`, `dev/git.nix`

**When NOT to use**: If you just need `inputs`, use Pattern D instead. TopLevel is only for reading `config.flake.*` data.

---

## Pattern Selection Decision Tree

```
Do you need packages (pkgs) or lib functions?
  No  -> Pattern A (pure config)
  Yes -> Do you need both NixOS and HM config?
    No  -> Pattern B (single namespace + pkgs/lib)
    Yes -> Do you need external flake inputs?
      No  -> Pattern C (dual-register)
      Yes -> Do you need flake-level metadata (config.flake.*)?
        No  -> Pattern D (inputs) + Pattern C (dual-register)
        Yes -> Pattern E (topLevel) + others as needed
```

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Using `{ inputs, ... }:` to get pkgs | `inputs` is for flake inputs only. Use `{ pkgs, ... }:` inside namespace value |
| Creating a new namespace for every file | HM namespaces are domain-aggregated. Multiple files write to `homeManager.shell` |
| Putting host-specific config in module | Modules define capabilities. Host specifics go in `hosts/` |
| Destructuring `{ inputs, ... }` when only needing pkgs | Only use inputs pattern when you actually need a flake input |
| Using `topLevel` when `inputs` would suffice | `topLevel` is specifically for `config.flake.*` data |
