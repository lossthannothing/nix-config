{
  inputs,
  lib,
  config,
  ...
}: let
  prefix = "hosts/";
in {
  flake.nixosConfigurations = lib.pipe config.flake.modules.nixos [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs' (
      name: module: let
        specialArgs = {
          inherit inputs;
          inherit (inputs) dotfiles;
          hostConfig = {
            name = lib.removePrefix prefix name;
          };
        };
      in {
        name = lib.removePrefix prefix name;
        value = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            module
            inputs.home-manager.nixosModules.home-manager
            {
              # 统一为所有 NixOS 配置设置 Home Manager 集成
              # useGlobalPkgs: 让 Home Manager 使用 NixOS 的 pkgs（包括 overlays）
              # useUserPackages: 将包安装到用户环境而不是系统环境
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      }
    ))
  ];
}
