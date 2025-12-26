# modules/dev/languages/nix.nix
#
# Nix 开发工具
{
  flake.modules = {
    homeManager.dev = {pkgs, ...}: {
      home.packages = [
        pkgs.nix-output-monitor # Nix 构建输出监控工具
      ];
    };
  };
}
