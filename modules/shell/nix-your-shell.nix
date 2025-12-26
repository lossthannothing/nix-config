# modules/shell/nix-your-shell.nix
#
# nix-your-shell - 更好的 nix-shell 体验

{
  flake.modules = {
    homeManager.shell = {
      programs.nix-your-shell = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
