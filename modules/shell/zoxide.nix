# modules/shell/zoxide.nix
#
# loss.shell._.zoxide — smart cd
{
  loss.shell._.zoxide.homeManager = {...}: {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };

    home.shellAliases.zi = "z -i";
  };
}
