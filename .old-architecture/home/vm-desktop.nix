# home/vm-desktop.nix
#
# VM Desktop Home Manager configuration
# 虚拟机桌面 Home Manager 配置

{ mylib, ... }:

{
  imports = [
    ./home.nix
    ./dev
    ./shell
    ./desktop.nix
  ];
}