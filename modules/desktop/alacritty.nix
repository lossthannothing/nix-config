# modules/desktop/alacritty.nix
#
# Alacritty - GPU-accelerated Wayland terminal
# Catppuccin Mocha themed via catppuccin/nix
{
  flake.modules.homeManager.desktop = {
    programs.alacritty = {
      enable = true;
      # Catppuccin theming inherited from global catppuccin.enable in theming.nix
      settings = {
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
          size = 13;
        };
        window = {
          opacity = 0.92;
          padding = {
            x = 6;
            y = 6;
          };
          decorations = "None";
        };
        scrolling.history = 10000;
      };
    };
  };
}
