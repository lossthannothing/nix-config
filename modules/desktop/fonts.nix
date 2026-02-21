# modules/desktop/fonts.nix
#
# Fonts - programming fonts (Nerd Fonts) + UI fonts (Lexend for waybar)
{
  flake.modules.homeManager.shell = {pkgs, ...}: {
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      lexend
    ];
  };
}
