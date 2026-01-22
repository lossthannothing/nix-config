# hosts/nixos-wsl/default.nix
{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos."hosts/nixos-wsl" = {...}: {
    imports = with config.flake.modules.nixos;
      [
        # 1. 外部依赖模块
        inputs.nixos-wsl.nixosModules.default

        # 2. 本地功能模块
        base
        rust
        wsl # <--- 这里导入的是 nixos.wsl (系统级)
        loss
      ]
      ++ [
        # 3. Home Manager 集成
        {
          home-manager.users.loss = {
            imports = with config.flake.modules.homeManager; [
              base
              shell
              dev
              wsl # <--- 这里导入的是 homeManager.wsl (用户级)
              loss
            ];
          };
        }
      ];
  };
}
