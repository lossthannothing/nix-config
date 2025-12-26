# modules/shell/sheldon.nix
#
# sheldon - ZSH 插件管理器

{ pkgs, dotfiles, ... }:

{
  flake.modules.homeManager.shell = {
    home.packages = with pkgs; [ sheldon ];

    home.file.".config/sheldon/plugins.toml".source =
      "${dotfiles}/config/.config/sheldon/plugins.toml";
  };
}
