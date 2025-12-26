# modules/cli-tools/lstr.nix
#
# lstr - 文件列表工具

{
  flake.modules = {
    homeManager.shell =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ lstr ];
      };
  };
}
