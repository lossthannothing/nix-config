# home/shell/cli-tools.nix
#
# Shell tools configuration module
# Shell 工具配置模块
#
# This module contains all shell-related tools and utilities
# including packages, programs and their configurations.

{
  config,
  pkgs,
  lib,
  dotfiles,
  ...
}:

{
  # Shell tools and utilities packages
  home.packages = with pkgs; [
    # 插件管理和工具
    sheldon
    fnm

    # 核心工具
    which
    lsd
    lstr
    fd
    hyperfine
    just
    neofetch
    # 解压工具 (支持 extract 函数)
    unzip
    p7zip
    xz
    cabextract

    (nerd-fonts.jetbrains-mono)
  ];

  # Shell-related programs
  programs = {
    bat.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
      ];
    };
  };

  # Shell tools related dotfiles
  home.file = {
    ".config/sheldon/plugins.toml".source = "${dotfiles}/config/.config/sheldon/plugins.toml";
  };
}
