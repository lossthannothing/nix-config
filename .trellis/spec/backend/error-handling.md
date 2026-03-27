# Troubleshooting & Common Errors

> How to diagnose and fix common NixOS configuration problems.

---

## Overview

NixOS configuration errors fall into three categories: evaluation errors (Nix language), build errors (derivation failures), and activation errors (runtime). This guide covers the most common issues and their solutions.

---

## Evaluation Errors

### Infinite Recursion

**Symptom**: `error: infinite recursion encountered`

**Common causes**:
- Module A reads config set by Module B, which reads config set by Module A
- Using `config` to set a value that depends on itself

**Fix**: Use `lib.mkDefault` to break the cycle, or restructure to avoid circular dependency.

### Attribute Not Found

**Symptom**: `error: attribute 'xyz' missing`

**Common causes**:
- Typo in option name
- Module not imported (NixOS namespace not in host's imports list)
- Using a package that doesn't exist in nixpkgs

**Fix**: Check spelling, verify the module is imported in the host, search nixpkgs for correct package name.

### Type Mismatch

**Symptom**: `error: A definition for option '...' is not of type '...'`

**Common causes**:
- Assigning wrong type (e.g., string where list expected)
- Merge conflict between two modules setting same option differently

**Fix**: Check the option's type in NixOS/HM docs. Use `lib.mkForce` if intentional override is needed.

---

## Build Errors

### Hash Mismatch

**Symptom**: `hash mismatch in fixed-output derivation`

**Fix**: Usually caused by stale `flake.lock`. Run `nix flake update` for the affected input.

### Package Build Failure

**Symptom**: Derivation build fails with compiler errors

**Fix**:
1. Check if the package is broken on unstable: search nixpkgs issues
2. Try pinning to a specific nixpkgs version
3. Add an overlay to patch the package

---

## Activation Errors

### Service Failed to Start

**Symptom**: `systemctl status <service>` shows failure after `nixos-rebuild switch`

**Fix**: Check logs with `journalctl -u <service> -e`, fix configuration, rebuild.

### Home Manager Conflict

**Symptom**: `Existing file '...' is in the way`

**Fix**: HM won't overwrite files it didn't create. Backup and remove the conflicting file, then retry.

---

## Debugging Techniques

### Interactive REPL

The REPL is the most powerful debugging tool:

```bash
nix repl
:lf .
# Explore NixOS config
:p outputs.nixosConfigurations.nixos-wsl.config.services.openssh
# Explore HM config
:p outputs.homeConfigurations."hosts/fedora-wsl".config.programs.git
# Check what a module evaluates to
:p outputs.nixosConfigurations.nixos-wsl.config.environment.systemPackages
```

### Dry Run

```bash
# See what would change without applying
nixos-rebuild dry-run --flake .#nixos-wsl
```

### Build Specific Host

```bash
# Build only, don't activate (safe for testing)
nixos-rebuild build --flake .#nixos-desktop
```

### Check Flake Outputs

```bash
# See all available outputs
nix flake show

# Check a specific output exists
nix eval .#nixosConfigurations.nixos-wsl.config.networking.hostName
```

---

## Namespace-Specific Issues

### Module Not Found in Host

**Symptom**: `error: attribute 'mymodule' missing at ...`

**Cause**: NixOS namespace exists in modules/ but not imported in host.

**Fix**: Add the namespace name to the host's `imports` list:
```nix
imports = with config.flake.modules.nixos; [
  base
  mymodule  # Add this
];
```

### Auto-Merge Conflict

**Symptom**: `error: The option '...' in '...' is already defined in '...'`

**Cause**: Two files in the same HM namespace set the exact same attribute.

**Fix**: Use `lib.mkDefault` in one, or combine with `lib.mkMerge`:
```nix
home.packages = lib.mkMerge [
  [pkgs.package-a]  # From file 1
  [pkgs.package-b]  # From file 2
];
```

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Debugging by guessing | Use `nix repl` to inspect actual evaluated config |
| Rebuilding full system for every change | Use `nixos-rebuild build` first (faster, no reboot) |
| Ignoring warnings | Warnings often indicate future breakage |
| Editing generated files | Edit the Nix source, not generated output files |
