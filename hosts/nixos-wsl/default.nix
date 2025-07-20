# hosts/nixos-wsl/default.nix
#
# NixOS-WSL host configuration
# 组合通用 NixOS 配置和 WSL 特定配置
#
# This file combines the base NixOS configuration with WSL-specific settings
# to create a complete system configuration for the nixos-wsl host.

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Import cross-platform base modules
    ../../modules/base/nix.nix
    ../../modules/base/i18n.nix
    ../../modules/base/users.nix

    # Import NixOS base modules
    ../../modules/nixos/base/system.nix
    ../../modules/nixos/base/networking.nix

    # Import WSL-specific configuration
    ../../modules/nixos/wsl.nix
  ];

  # Host-specific configurations
  # Override the general hostname for this specific WSL instance.
  networking.hostName = "nixos-wsl";

  # Additional host-specific configurations can be added here if needed
  # For example:
  # - Host-specific networking settings
  # - Host-specific services
  # - Host-specific hardware configurations
}
