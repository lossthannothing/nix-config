# modules/dev/languages/rust.nix
#
# Rust 开发环境

{
  flake.modules = {
    homeManager.dev = { pkgs, ... }: {
      home.packages = [
        pkgs.rust-bin.stable.latest.default
      ];
    };
  };
}
