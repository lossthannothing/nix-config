# hosts/nixos-vm/vm-options.nix
#
# NixOS VM host configuration
# NixOS 虚拟机主机配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Import base OS configuration
    ../../os/base.nix
    # Import system packages
    ../../os/system-pkgs.nix
    # Import VM platform configuration
    ../../os/platforms/vm.nix
    # Import desktop features
    ../../os/features/desktop.nix
    # Import desktop packages
    ../../os/features/desktop-pkgs.nix
    # Import hardware configuration
    ./hardware.nix
  ];

  # VM-specific configurations can be added here if needed
}