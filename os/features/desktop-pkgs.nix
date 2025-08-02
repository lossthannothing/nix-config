# os/features/desktop-pkgs.nix
#
# Desktop environment system packages
# 桌面环境系统包

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Desktop-related system packages
  environment.systemPackages = with pkgs; [
    # Display and graphics
    xorg.xrandr
    xorg.xdpyinfo
    
    # Audio utilities
    pavucontrol
    
    # System utilities for desktop
    polkit
    polkit_gnome
  ];
}