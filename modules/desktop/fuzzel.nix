# modules/desktop/fuzzel.nix
#
# Fuzzel - Wayland-native application launcher
# Catppuccin Mocha themed
{
  flake.modules.homeManager.desktop = {
    programs.fuzzel = {
      enable = true;
      # Catppuccin theming inherited from global catppuccin.enable in theming.nix
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=13";
          terminal = "alacritty -e";
          layer = "overlay";
          prompt = "❯ ";
        };
        border = {
          width = 2;
          radius = 10;
        };
      };
    };
  };
}
