# modules/shell/yazi.nix
#
# Yazi - blazing fast TUI file manager in Rust
# Catppuccin themed, image preview support
{
  flake.modules.homeManager.shell = {
    programs.yazi = {
      enable = true;
      # Catppuccin theming inherited from global catppuccin.enable in theming.nix
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = false;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
    };
  };
}
