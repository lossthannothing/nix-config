# modules/cli-tools/archive.nix
#
# 压缩/解压工具集合
# 支持 zsh extract 函数的各种格式
{
  flake.modules = {
    homeManager.shell = {pkgs, ...}: {
      home.packages = with pkgs; [
        unzip
        p7zip
        cabextract
      ];
    };
  };
}
