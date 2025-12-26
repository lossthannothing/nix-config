# home/dev/dev-tools.nix
#
# Development tools configuration module
# 开发工具配置模块
#
# This module contains all development-related packages and programs
# including editors, language tools, and development utilities.
{
  config,
  pkgs,
  dotfiles,
  ...
}:
{
  # Development packages
  home.packages = with pkgs; [
    neovim
    lunarvim
    uv
    fnm
    deno
    rustup
    ansible
    nixfmt-rfc-style
    devenv
    nix-output-monitor # Better Nix build output visualization
  ];

  # Development programs
  programs = {
    go.enable = true;
    bun.enable = true;
  };

  # Development-related dotfiles and configurations
  home.file = {
    "./.config/lvim/config.lua".source = "${dotfiles}/config/.config/lvim/config.lua";

    # 单文件放宽- 不会锁定文件读写权限
    ".claude/commands/spec.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/commands/spec.md";
    };
  };
}
