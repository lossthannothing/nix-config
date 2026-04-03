# modules/shell/fzf.nix
#
# loss.shell._.fzf — fuzzy finder
{
  loss.shell._.fzf.homeManager = {...}: {
    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
      ];
    };
  };
}
