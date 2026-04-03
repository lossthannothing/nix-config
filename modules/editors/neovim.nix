# modules/editors/neovim.nix
#
# loss.editors._.neovim — neovim editor
{
  loss.editors._.neovim.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [neovim];
  };
}
