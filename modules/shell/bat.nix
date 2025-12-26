# modules/shell/bat.nix
#
# bat - cat 的现代替代品

{ pkgs, ... }:

{
  flake.modules.homeManager.shell = {
    programs.bat = {
      enable = true;
      config.theme = "TwoDark";
    };
  };
}
