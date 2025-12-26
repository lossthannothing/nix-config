# modules/dev/just.nix
#
# just - 命令运行器

{
  flake.modules = {
    homeManager.dev = { pkgs, ... }: {
      home.packages = with pkgs; [ just ];
    };
  };
}
