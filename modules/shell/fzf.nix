# modules/shell/fzf.nix
#
# fzf - 模糊查找工具

{ pkgs, ... }:

{
  flake.modules.homeManager.shell = {
    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
      ];
    };
  };
}
