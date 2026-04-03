# modules/dev/tools.nix
#
# loss.dev._.tools — development utilities (direnv, ripgrep, ansible, devenv, hyperfine, just)
{
  loss.dev._.tools.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      ansible
      devenv
      hyperfine
      just
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };
  };
}
