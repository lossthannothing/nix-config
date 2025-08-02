# os/platforms/wsl-pkgs.nix
#
# WSL platform-specific system packages
# WSL 平台特定的系统包

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # WSL-specific system packages
  environment.systemPackages = with pkgs; [
    wslu # WSL utilities
  ];
}