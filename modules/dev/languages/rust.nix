# modules/dev/languages/rust.nix
#
# Rust 开发环境
{config, ...}: {
  flake.modules = {
    homeManager.dev = {pkgs, ...}: {
      nixpkgs.overlays = [
        # 引用 flake-parts/nixpkgs.nix 中定义的 overlay
        config.flake.overlays.rust
      ];

      home.packages = [
        pkgs.rust-bin.stable.latest.default
      ];
    };
  };
}
