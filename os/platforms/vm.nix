# os/platforms/vm.nix
#
# Virtual Machine platform-specific configuration
# 虚拟机平台特定配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Boot configuration for VM
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Graphics drivers for VM
  services.xserver.videoDrivers = [ "vmware" "virtualbox" "qxl" ];

  # Enable guest additions for better VM integration
  virtualisation.vmware.guest.enable = true;
  virtualisation.virtualbox.guest.enable = true;

  # VM-specific optimizations
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}