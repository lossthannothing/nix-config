# modules/dev/tools/devenv.nix
#
# devenv - Nix 开发环境管理工具
{
  flake.modules = {
    homeManager.dev =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.devenv ];
      };
  };
}
