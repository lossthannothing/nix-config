# modules/shell/zoxide.nix
#
# zoxide - 智能目录跳转工具

{ pkgs, ... }:

{
  flake.modules.homeManager.shell = {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };
  };
}
