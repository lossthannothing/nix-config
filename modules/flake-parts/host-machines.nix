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
            # 引入 Home Manager 的 NixOS 模块以支持 home-manager.users 选项
            inputs.home-manager.nixosModules.home-manager
            {
              # --- 解绑核心修改 ---
              # 1. 不再强制 Home Manager 使用全局 NixOS pkgs
              # 这允许 Home Manager 模块独立实例化自己的 pkgs，从而支持 Non-NixOS 场景
              home-manager.useGlobalPkgs = false;

              # 2. 依然将包安装到用户环境
              home-manager.useUserPackages = true;

              # 3. 传递特殊的构建参数
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      }
    ))
  ];
}
