# modules/editors/default.nix
#
# loss.editors — aggregation: all editor tools
{
  loss.editors = {
    includes = with loss; [
      editors._.neovim
    ];
  };
}
