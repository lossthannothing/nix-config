{
  inputs,
  lib,
  config,
  ...
}: let
  prefix = "hosts/";
in {
  # 必须导入 HM 提供的 flakeModule 才能启用 flake.homeConfigurations 选项
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  # 1. 映射 NixOS 入口 (保持你之前的解绑修改)
  flake.nixosConfigurations = lib.pipe config.flake.modules.nixos [
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs' (
      name: module: let
        specialArgs = {
          inherit inputs;
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
              # 解绑核心：不再强制使用全局 pkgs，支持模块独立实例化
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      }
    ))
  ];

  # 2. 新增：独立 Home Manager 入口 (用于 Fedora 等 Standalone 场景)
  # 这将解决 "does not provide attribute" 报错
  flake.homeConfigurations = lib.pipe config.flake.modules.homeManager [
    # 过滤出 hosts/ 目录下的配置
    (lib.filterAttrs (name: _: lib.hasPrefix prefix name))
    (lib.mapAttrs (
      name: module:
        inputs.home-manager.lib.homeManagerConfiguration {
          # 独立模式必须显式指定 pkgs 实例
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

          extraSpecialArgs = {
            inherit inputs;
            hostConfig = {
              name = lib.removePrefix prefix name;
            };
          };

          modules = [
            module
            # 针对非 NixOS 系统自动开启兼容层
            {
              targets.genericLinux.enable = true;
            }
          ];
        }
    ))
  ];
}
