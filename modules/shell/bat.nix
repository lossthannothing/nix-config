# modules/shell/bat.nix
#
# loss.shell._.bat — cat replacement
{
  loss.shell._.bat.homeManager = {lib, ...}: {
    programs.bat = {
      enable = true;
      config.theme = lib.mkDefault "TwoDark";
    };

    home.shellAliases.cat = "bat";
  };
}
