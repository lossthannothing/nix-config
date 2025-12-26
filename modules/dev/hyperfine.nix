# modules/dev/hyperfine.nix
#
# hyperfine - 命令行基准测试工具
{
  flake.modules = {
    homeManager.dev =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ hyperfine ];
      };
  };
}
