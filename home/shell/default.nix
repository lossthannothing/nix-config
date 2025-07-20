# home/shell/default.nix
#
# Shell configuration module entry point
# Shell 配置模块入口
#
# This file imports all shell-related configurations

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # ZSH configuration module
    # ZSH 配置模块
    ./zsh.nix

    # Shell tools configuration module
    # Shell 工具配置模块
    ./tools.nix
  ];
}
