# modules/nixpkgs.nix
#
# perSystem pkgs instance and flake-level overlays
# Migrated from: flake-parts/nixpkgs.nix
{
  inputs,
  withSystem,
  ...
}: {
  systems = ["x86_64-linux"];

  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [];
      config = {
        allowUnfreePredicate = _pkg: true;
      };
    };
  };

  flake.overlays = {
    default = _final: prev: {
      local = withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
    };
  };
}
