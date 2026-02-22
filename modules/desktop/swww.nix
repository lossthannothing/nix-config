# modules/desktop/swww.nix
#
# SWWW - efficient animated wallpaper daemon for Wayland
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    home.packages = [pkgs.swww];
  };
}
