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

          # Catppuccin Mocha colors
          inside-color = "1e1e2e";
          ring-color = "b4befe";
          key-hl-color = "a6e3a1";
          bs-hl-color = "f38ba8";
          text-color = "cdd6f4";
          inside-clear-color = "1e1e2e";
          ring-clear-color = "f9e2af";
          text-clear-color = "cdd6f4";
          inside-ver-color = "1e1e2e";
          ring-ver-color = "89b4fa";
          text-ver-color = "cdd6f4";
          inside-wrong-color = "1e1e2e";
          ring-wrong-color = "f38ba8";
          text-wrong-color = "cdd6f4";
          line-color = "00000000";
          separator-color = "00000000";
        };
      };
    };
  };
}
