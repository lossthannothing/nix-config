# modules/dev/rust.nix
#
# loss.dev._.rust - Rust development environment
{inputs, ...}: {
  loss.dev._.rust = {
    nixos = {
      nixpkgs.overlays = [
        inputs.rust-overlay.overlays.default
      ];
    };

    homeManager = {pkgs, ...}: {
      nixpkgs.overlays = [
        inputs.rust-overlay.overlays.default
      ];
      home.packages = [
        pkgs.rust-bin.stable.latest.default
      ];
    };
  };
}
