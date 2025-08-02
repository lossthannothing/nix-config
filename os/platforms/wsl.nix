# os/platforms/wsl.nix
#
# WSL platform-specific configuration
# WSL 平台特定配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # WSL-specific settings
  wsl = {
    enable = true;
    defaultUser = "loss";
    startMenuLaunchers = true;

    # Enable integration with Windows
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = false;
  };

  # Disable boot loader (not needed in WSL)
  boot.loader.grub.enable = false;

  # Disable systemd services that don't work in WSL
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-networkd.enable = false;

  # Network configuration for WSL
  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useNetworkd = false;
  };


}