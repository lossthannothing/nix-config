# lib/homeManagerSystem.nix
#
# Helper function to generate Home Manager configurations
# 用于生成 Home Manager 配置的辅助函数

{
  inputs,
  lib,
  system,
  home-modules ? [],
  specialArgs ? {},
  myvars,
  ...
}:
let
  inherit (inputs) nixpkgs home-manager;
in
home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.${system};
  modules = home-modules;
  extraSpecialArgs = specialArgs;
}
