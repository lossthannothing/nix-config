# modules/desktop/theming.nix
#
# Catppuccin Mocha system-wide theming
# GTK, Qt, cursor, icons
# Requires catppuccin/nix homeModules.catppuccin imported in host
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    # Catppuccin global settings (applied to all supported programs)
    catppuccin = {
      flavor = "mocha";
      accent = "blue";
      enable = true;
    };

    # GTK theming
    gtk = {
      enable = true;
      catppuccin.enable = true;
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };
    };

    # Qt theming
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    # Catppuccin Kvantum theme for Qt apps
    home.packages = with pkgs; [
      catppuccin-kvantum
    ];

    # Cursor
    home.pointerCursor = {
      package = pkgs.catppuccin-cursors.mochaBlue;
      name = "catppuccin-mocha-blue-cursors";
      size = 24;
      gtk.enable = true;
    };
  };
}
