# modules/dev/javascript.nix
#
# JavaScript/TypeScript 开发环境
{
  flake.modules = {
    homeManager.dev = {pkgs, ...}: {
      home.packages = with pkgs; [
        fnm # Fast Node Manager - Node 版本管理
        deno # Deno 运行时
      ];

      programs.bun.enable = true;
    };
  };
}
