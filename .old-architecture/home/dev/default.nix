# home/dev/default.nix
#
# Development modules entry point
# 开发模块入口点
{mylib, ...}: {
  imports = mylib.scanPaths ./.;
}
