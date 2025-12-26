# modules/shell/fd.nix
#
# fd - find 的现代替代品

{ pkgs, ... }:

{
  flake.modules.homeManager.shell = {
    home.packages = with pkgs; [ fd ];
  };
}
