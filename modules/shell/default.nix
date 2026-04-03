# modules/shell/default.nix
#
# loss.shell — aggregation: all terminal/shell tools
{
  loss.shell = {
    includes = with loss; [
      shell._.zsh
      shell._.starship
      shell._.git
      shell._.bat
      shell._.eza
      shell._.fzf
      shell._.fd
      shell._.zoxide
      shell._.yazi
      shell._.misc
    ];
  };
}
