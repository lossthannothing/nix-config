# modules/system/default.nix
#
# loss.system — aggregation: nix + locale
# (WSL sub-aspect included separately by hosts)
{
  loss.system = {
    includes = with loss; [
      system._.nix
      system._.locale
    ];
  };
}
