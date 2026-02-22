# modules/desktop/fcitx5.nix
#
# Fcitx5 + RIME Chinese input method
# Dual registration: NixOS input method + HM config
{
  flake.modules = {
    # NixOS: enable input method framework
    nixos.fcitx5 = {pkgs, ...}: {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-rime
          fcitx5-chinese-addons
          fcitx5-gtk
        ];
      };
    };

    # HM: Wayland environment variables for input method
    homeManager.desktop = {
      home.sessionVariables = {
        XMODIFIERS = "@im=fcitx";
        GTK_IM_MODULE = "fcitx";
        QT_IM_MODULE = "fcitx";
      };
    };
  };
}
