# os/spec/wsl-pkgs.nix
#
# WSL-specific system packages (migrated from os/platforms/wsl-pkgs.nix)

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
