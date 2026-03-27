# Host & Infrastructure Directory Structure

> How hosts and flake-parts infrastructure are organized.

---

## Overview

The project has two infrastructure areas:
- `hosts/` — Instance configurations that compose modules into deployable systems
- `modules/flake-parts/` — Framework infrastructure that powers the module system

---

## Hosts Directory Layout

```
hosts/
|-- nixos-wsl/
|   +-- default.nix          # NixOS-WSL host configuration
|-- nixos-desktop/
|   |-- default.nix          # NixOS physical desktop configuration
|   +-- facter.json          # Hardware detection data (auto-generated)
|-- nixos-vm/
|   +-- default.nix          # NixOS VM configuration (testing)
+-- fedora-wsl/
    +-- default.nix          # Fedora WSL (standalone HM host)
```

### Host Types

| Type | Registration | Example |
|------|-------------|---------|
| NixOS host | `flake.modules.nixos."hosts/<name>"` | nixos-wsl, nixos-desktop, nixos-vm |
| Standalone HM host | `flake.modules.homeManager."hosts/<name>"` | fedora-wsl |

---

## flake-parts Infrastructure Layout

```
modules/flake-parts/
|-- flake-parts.nix      # Enables flake.modules.* namespace options
|-- flake.nix            # flake.meta option (user metadata definition)
|-- host-machines.nix    # Core engine: hosts/ -> nixosConfigurations
|-- nixpkgs.nix          # perSystem pkgs instance + flake overlays
+-- fmt.nix              # treefmt-nix formatting (15+ tools)
```

**CRITICAL**: These files are the foundation of the entire project. Modifying them requires explicit review approval.

### What Each File Does

| File | Role | Impact of Breaking It |
|------|------|----------------------|
| `flake-parts.nix` | Defines `flake.modules.nixos.*` and `flake.modules.homeManager.*` options | All modules stop working |
| `flake.nix` | Defines `flake.meta` option for project metadata | Metadata references break |
| `host-machines.nix` | Transforms `flake.modules.*.hosts/*` into `nixosConfigurations` | No hosts can be built |
| `nixpkgs.nix` | Creates `perSystem` pkgs instance, applies overlays | Package resolution breaks |
| `fmt.nix` | Configures all formatting tools | `nix fmt` stops working |

---

## NixOS Host Configuration Pattern

All NixOS hosts follow this assembly pattern:

```nix
# hosts/nixos-wsl/default.nix
{ config, inputs, ... }: {
  flake.modules.nixos."hosts/nixos-wsl" = { ... }: {
    imports =
      with config.flake.modules.nixos; [
        # 1. External dependency modules
        inputs.nixos-wsl.nixosModules.default

        # 2. Local NixOS modules (by namespace name)
        base
        wsl
        loss
      ]
      ++ [
        # 3. Home Manager integration block
        {
          home-manager.users.loss = {
            imports = with config.flake.modules.homeManager; [
              base
              shell
              dev
              loss
              wsl
            ];
          };
        }
      ];

    # 4. Host-specific inline config
    networking.hostName = "nixos-wsl";
  };
}
```

### Assembly Structure (4 Sections)

1. **External modules**: Import from flake inputs (`inputs.*.nixosModules.*`)
2. **Local NixOS modules**: Reference by namespace name via `with config.flake.modules.nixos`
3. **HM integration**: Nested `home-manager.users.<user>.imports` with HM module namespaces
4. **Host-specific overrides**: Inline config unique to this host (hostname, boot, disko, etc.)

---

## Standalone HM Host Pattern

For non-NixOS systems (e.g., Fedora WSL):

```nix
# hosts/fedora-wsl/default.nix
{ config, ... }: {
  flake.modules.homeManager."hosts/fedora-wsl" = { ... }: {
    imports = with config.flake.modules.homeManager; [
      base  shell  dev  loss  wsl
    ];
    home = {
      username = "loss";
      homeDirectory = "/home/loss";
    };
  };
}
```

**Key differences from NixOS hosts:**
- Registers to `flake.modules.homeManager."hosts/..."` (not nixos)
- Must manually specify `home.username` and `home.homeDirectory`
- No NixOS modules available (no system-level config)
- `genericLinux` is auto-injected by `host-machines.nix` for compatibility

---

## Adding a New Host

### NixOS Host

1. Create `hosts/<hostname>/default.nix`
2. Follow the 4-section assembly pattern above
3. Choose which NixOS and HM modules to import
4. Add host-specific config (hostname, boot, etc.)
5. For physical hardware: generate `facter.json` and import `facter` module

### Standalone HM Host

1. Create `hosts/<hostname>/default.nix`
2. Follow the standalone HM pattern above
3. Specify `home.username` and `home.homeDirectory`
4. Choose which HM modules to import

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Putting reusable config in hosts/ | Hosts should only assemble modules. Move reusable config to modules/ |
| Forgetting to quote host namespace | Must be `"hosts/my-host"` with quotes (contains `/`) |
| Importing modules by file path | Use namespace names: `with config.flake.modules.nixos; [base wsl]` |
| Modifying flake-parts/ without review | Always get review approval first |
