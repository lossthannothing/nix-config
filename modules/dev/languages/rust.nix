# modules/dev/languages/rust.nix
#
# Rust 开发环境

{ inputs, ... }:
{
  flake.modules = {
    homeManager.dev = { pkgs, ... }: {
      nixpkgs.overlays = [
        inputs.rust-overlay.overlays.default
      ];

      home.packages = [
        pkgs.rust-bin.stable.latest.default
      ];
    };
  };
}
