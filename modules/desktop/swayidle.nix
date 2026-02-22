# modules/desktop/swayidle.nix
#
# swayidle - idle management for Wayland
# Lock after 300s, screen off after 600s
# Note: Modern apps (Firefox, mpv) send idle-inhibit signals for fullscreen video
{
  flake.modules.homeManager.desktop = {
    services.swayidle = {
      enable = true;
      events = {
        before-sleep = "swaylock -f";
        lock = "swaylock -f";
      };
      timeouts = [
        {
          timeout = 300;
          command = "swaylock -f";
        }
        {
          timeout = 600;
          command = "niri msg action power-off-monitors";
          resumeCommand = "niri msg action power-on-monitors";
        }
      ];
    };
  };
}
