# modules/flake-parts/host-machines.nix
#
# 自动生成 nixosConfigurations 的生成器
# 从 flake.modules.nixos 中提取所有 "hosts/*" 模块并生成对应的系统配置

{
  inputs,
  lib,
  config,
  ...
}:
let
  prefix = "hosts/";
in
{
  flake.nixosConfigurations = lib.pipe config.flake.modules.nixos [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs' (
      name: module:
      let
        specialArgs = {
          inherit inputs;
          hostConfig = {
            name = lib.removePrefix prefix name;
          };
        };
      in
      {
        name = lib.removePrefix prefix name;
        value = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            module
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      }
    ))
  ];
}
