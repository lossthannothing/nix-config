# modules/shell/lsd.nix
#
# lsd - ls 的现代替代品

{ pkgs, ... }:

{
  flake.modules.homeManager.shell = {
    home.packages = with pkgs; [ lsd ];
  };
}
