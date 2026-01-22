# hosts/fedora-wsl/default.nix (注意文件名修正)
{config, ...}: {
  flake.modules.homeManager."hosts/fedora-wsl" = {...}: {
    imports = with config.flake.modules.homeManager; [
      base
      shell
      dev
      loss
      wsl # <--- 直接复用，无需复制粘贴代码
    ];

    home = {
      username = "loss";
      homeDirectory = "/home/loss";
    };

    targets.genericLinux.enable = true;
  };
}
