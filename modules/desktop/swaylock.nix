# modules/desktop/swaylock.nix
#
# swaylock-effects - screen locker with blur & clock
# Dual registration: NixOS PAM + HM config
{
  flake.modules = {
    # NixOS: PAM service for swaylock authentication
    nixos.swaylock = {
      security.pam.services.swaylock = {};
    };

    # HM: swaylock-effects with Catppuccin Mocha colors
    homeManager.desktop = {pkgs, ...}: {
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          # Effects
          screenshots = true;
          effect-blur = "10x3";
          effect-vignette = "0.5:0.5";
          fade-in = 0.2;

          # Clock
          clock = true;
          timestr = "%H:%M";
          datestr = "%Y-%m-%d";

          # Indicator
          indicator = true;
          indicator-radius = 120;
          indicator-thickness = 10;

          # Colors managed by catppuccin.enable in theming.nix
        };
      };
    };
  };
}
