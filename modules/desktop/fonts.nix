# modules/cli-tools/fonts.nix
#
# Nerd Fonts - 包含图标的编程字体
{
  flake.modules.homeManager.shell = {pkgs, ...}: {
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };
}
