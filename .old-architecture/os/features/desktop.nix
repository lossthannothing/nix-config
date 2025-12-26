# os/features/desktop.nix
#
# Desktop environment system-level configuration
# 桌面环境系统级配置
{pkgs, ...}: {
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

  # Input method support - 输入法支持
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5"; # Use fcitx5 instead of ibus for better Wayland support
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-chinese-addons
      fcitx5-gtk
      fcitx5-configtool
    ];
  };

  # Environment variables for input method - 输入法环境变量
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
    SDL_IM_MODULE = "fcitx"; # Support for SDL applications
    NIXOS_OZONE_WL = "1"; # Enable Wayland support for Electron apps
  };

  # Font configuration - 字体配置
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    sarasa-gothic # 更纱黑体 - Better CJK font
    source-code-pro
    hack-font
    fira-code
    nerd-fonts.fira-code # Nerd Fonts version
    jetbrains-mono
  ];
}
