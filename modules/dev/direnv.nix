# modules/dev/direnv.nix
#
# direnv - 自动加载项目环境变量
{
  flake.modules = {
    homeManager.dev = _: {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true; # 为 Nix 项目提供更好的集成和缓存
      };
    };
  };
}
