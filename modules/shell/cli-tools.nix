# modules/shell/cli-tools.nix
#
# 基础 CLI 工具集合

{ pkgs, ... }:

{
  flake.modules.homeManager.shell = {
    home.packages = with pkgs; [
      # Node 版本管理
      fnm

      # 基础工具
      which
      lstr
      hyperfine
      just
      neofetch

      # 解压工具（支持 extract 函数）
      unzip
      p7zip
      xz
      cabextract

      # 字体
      (nerd-fonts.jetbrains-mono)
    ];
  };
}
