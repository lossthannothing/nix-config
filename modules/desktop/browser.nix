# modules/desktop/browser.nix
#
# Brave - privacy-focused Chromium-based browser
# Wayland native
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    home.packages = [pkgs.brave];

    # Wayland flags for Chromium-based browsers
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
