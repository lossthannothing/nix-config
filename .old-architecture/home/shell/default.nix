# home/shell/default.nix
#
# Shell modules entry point
# Shell 模块入口点
{mylib, ...}: {
  imports = mylib.scanPaths ./.;
}
