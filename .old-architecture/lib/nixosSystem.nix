# lib/nixosSystem.nix
#
# Helper function to generate NixOS system configurations
# 用于生成 NixOS 系统配置的辅助函数
{
  inputs,
  lib,
  system,
  nixos-modules,
  home-modules ? [],
  specialArgs ? {},
  myvars,
  ...
}: let
  inherit (inputs) nixpkgs home-manager;
in
  nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
      nixos-modules
      ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "home-manager.backup";

          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users."${myvars.username}".imports = home-modules;
        }
      ]);
  }
