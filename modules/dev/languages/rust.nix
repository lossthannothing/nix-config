# modules/dev/languages/rust.nix
#
# Rust 开发环境 - 分工合作模式
{inputs, ...}: {
  flake.modules = {
    # 1. NixOS 模块：负责"生产" - 在系统级别注入 overlay
    nixos.rust = {
      nixpkgs.overlays = [
        inputs.rust-overlay.overlays.default
      ];
    };

    # 2. Home Manager 模块：负责"消费" - 安装 Rust 工具链
    # 假设 pkgs 已经包含 rust-bin (由 nixos.rust 或 perSystem 提供)
    homeManager.dev = {pkgs, ...}: {
      home.packages = [
        pkgs.rust-bin.stable.latest.default
      ];
    };
  };
}
