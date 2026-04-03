# modules/shell/eza.nix
#
# loss.shell._.eza — ls replacement
{
  loss.shell._.eza.homeManager = {...}: {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    home.shellAliases = {
      ls = "eza";
      ll = "eza -lh --git";
      la = "eza -lah --git";
    };
  };
}
