# modules/desktop/screenshot.nix
#
# Screenshot, screen recording, and clipboard management
# grim + slurp + satty + wf-recorder + wl-clipboard + cliphist
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    home.packages = with pkgs; [
      grim # Screenshot
      slurp # Region selection
      satty # Screenshot annotation
      wf-recorder # Screen recording
      wl-clipboard # Wayland clipboard
      cliphist # Clipboard history
    ];
  };
}
