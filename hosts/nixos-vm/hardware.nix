# hosts/nixos-vm/hardware.nix
#
# VM hardware-specific configuration
# 虚拟机硬件特定配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # VM-specific hardware configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # Host-specific configurations
  networking.hostName = "nixos-vm";

  # System state version
  system.stateVersion = "24.05";
}