# modules/dev/python.nix
#
# Python 开发环境
{
  flake.modules = {
    homeManager.dev = {
      programs.uv.enable = true;
    };
  };
}
