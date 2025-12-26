# modules/base/console/default.nix
#
# Console 和 Shell 配置
{
  flake.modules = {
    homeManager.base = {
      programs.zsh.enable = true;
    };

    nixos.base =
      { pkgs, ... }:
      {
        users.defaultUserShell = pkgs.zsh;
        programs.zsh.enable = true;

        console = {
          earlySetup = true;
          useXkbConfig = true;
        };
      };
  };
}
