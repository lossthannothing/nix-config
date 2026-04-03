# modules/shell/fd.nix
#
# loss.shell._.fd — find replacement
{
  loss.shell._.fd.homeManager = {...}: {
    programs.fd.enable = true;
  };
}
