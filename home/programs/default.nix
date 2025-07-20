# home/programs/default.nix
#
# Programs configuration module entry point
# 程序配置模块入口
#
# This file imports all program-related configurations

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Git configuration module
    # Git 配置模块
    ./git.nix

    # Development tools configuration module
    # 开发工具配置模块
    ./development.nix
  ];
}
