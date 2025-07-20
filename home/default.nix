# home/default.nix
#
# Home Manager configuration entry point
# Home Manager 配置统一入口
#
# This file imports all Home Manager modules and serves as the main entry point
# for user configuration. It replaces the previous approach of importing
# individual files directly in flake.nix.

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Base Home Manager configuration (renamed from home.nix)
    # 基础 Home Manager 配置（从 home.nix 重命名而来）
    ./base.nix
    
    # Program configurations (development tools, git, etc.)
    # 程序配置（开发工具、git 等）
    ./programs
    
    # Shell configurations (zsh, shell tools, etc.)
    # Shell 配置（zsh、shell 工具等）
    ./shell
  ];

  # This file serves as a unified entry point for all Home Manager configurations.
  # Individual configurations are organized into logical modules under subdirectories.
  # 此文件作为所有 Home Manager 配置的统一入口点。
  # 各个配置被组织到子目录下的逻辑模块中。
}
