# modules/desktop/media.nix
#
# Media viewers and players
# Catppuccin theming inherited from global catppuccin.enable in theming.nix
# mpv, imv, zathura, cava
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    # mpv - video player
    programs.mpv.enable = true;

    # zathura - document viewer
    programs.zathura.enable = true;

    # cava - audio spectrum visualizer
    programs.cava.enable = true;

    # imv - Wayland image viewer
    home.packages = [pkgs.imv];
  };
}
