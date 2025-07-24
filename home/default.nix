# home/default.nix
#
# Home Manager configuration entry point
# Home Manager 配置入口点

{ mylib, ... }:

{
  imports = [
    ./home.nix
    ./dev
    ./shell
  ];
}
