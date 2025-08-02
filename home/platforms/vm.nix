# home/platforms/vm.nix
#
# VM platform-specific Home Manager configuration
# 虚拟机平台特定的 Home Manager 配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # VM-specific user environment settings
  home.sessionVariables = {
    # VM-specific display settings
    GDK_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  # VM-specific packages
  home.packages = with pkgs; [
    # VM guest tools
    spice-vdagent
    
    # Clipboard sharing
    xclip
    wl-clipboard
  ];

  # VM-specific services (spice-vdagent is system-level, not home-manager)
  # services.spice-vdagent should be configured at system level
}