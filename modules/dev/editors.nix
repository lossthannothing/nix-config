# modules/dev/editors.nix
#
# 编辑器配置
{
  flake.modules = {
    homeManager.dev = {pkgs, ...}: {
      home.packages = with pkgs; [
        neovim
      ];
    };
  };
}
