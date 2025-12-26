# modules/dev/go.nix
#
# Go 开发环境
{
  flake.modules = {
    homeManager.dev = {
      programs.go.enable = true;
    };
  };
}
