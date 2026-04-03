# modules/shell/yazi.nix
#
# loss.shell._.yazi — terminal file manager
{
  loss.shell._.yazi.homeManager = {...}: {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = false;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
    };
  };
}
