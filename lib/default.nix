# lib/default.nix
#
# Helper functions library to reduce code duplication in flake.nix
# 辅助函数库，用于减少 flake.nix 中的代码重复并提高可维护性

{ lib, ... }:

{
  # Import helper modules
  nixosSystem = import ./nixosSystem.nix;

  # Common configurations and variables
  vars = import ./vars.nix;

  # Scan paths for nix files (useful for auto-importing modules)
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") # include directories
          || (
            (path != "default.nix") # ignore default.nix
            && (lib.strings.hasSuffix ".nix" path) # include .nix files
          )
        ) (builtins.readDir path)
      )
    );
}
