# os/features/desktop.nix
#
# Desktop environment system-level configuration
# 桌面环境系统级配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
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
}