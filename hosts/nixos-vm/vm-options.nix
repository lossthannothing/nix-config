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
    # Import core OS configuration
    ../../os/configuration.nix
  ];

  # Host-specific configurations
  networking.hostName = "nixos-vm";

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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable graphics and desktop environment support
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  
  # Enable Wayland and desktop environments
  programs.hyprland.enable = true;
  programs.sway.enable = true;
  programs.niri.enable = true;

  # XDG portal configuration for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Audio support
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  # Input method support
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      libpinyin
      rime
    ];
  };

  # Font configuration
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    sarasa-gothic
    source-code-pro
    hack-font
    fira-code
    nerd-fonts.fira-code
    jetbrains-mono
  ];

  # Graphics drivers for VM
  services.xserver.videoDrivers = [ "vmware" "virtualbox" "qxl" ];

  # Enable guest additions for better VM integration
  virtualisation.vmware.guest.enable = true;
  virtualisation.virtualbox.guest.enable = true;

  # System state version
  system.stateVersion = "24.05";
}