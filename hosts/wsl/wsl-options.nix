# hosts/wsl/wsl-options.nix
#
# WSL host configuration
# WSL 主机配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Import core OS configuration (includes system-pkgs.nix via auto-scan)
    ../../os/configuration.nix
    # Import WSL-specific configuration
    ../../os/wsl.nix
  ];

  # Host-specific configurations
  networking.hostName = "nixos-wsl";

  # System state version
  system.stateVersion = "24.05";
}
