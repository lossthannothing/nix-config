# modules/dev/editors.nix
#
# 编辑器配置

{
  flake.modules = {
    homeManager.dev = { pkgs, dotfiles, ... }: {
      home.packages = with pkgs; [
        neovim
        lunarvim
      ];

      # LunarVim 配置
      home.file."./.config/lvim/config.lua".source = "${dotfiles}/config/.config/lvim/config.lua";
    };
  };
}
