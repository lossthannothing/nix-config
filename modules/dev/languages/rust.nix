# modules/dev/languages/rust.nix
#
# Rust 开发环境 - 跨平台解耦模式
{inputs, ...}: {
  flake.modules = {
    # 1. NixOS 模块：负责系统级别的 Overlay 注入
    nixos.rust = {
      nixpkgs.overlays = [
        inputs.rust-overlay.overlays.default
      ];
    };

    # 2. Home Manager 模块：实现自给自足
    # 统一 FP 接口规范，显式声明 _pkgs
    homeManager.dev = {pkgs, ...}: {
      # 关键修改：在 HM 层面显式注入 Overlay
      # 这样无论 host-machines.nix 是否开启 useGlobalPkgs，
      # 或者是否在 Non-NixOS 环境下运行，pkgs 都能正确获得 rust-bin 属性。
      nixpkgs.overlays = [
        inputs.rust-overlay.overlays.default
      ];

      home.packages = [
        pkgs.rust-bin.stable.latest.default
      ];
    };
  };
}
