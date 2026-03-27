# modules/dev/nix.nix
#
# loss.dev._.nix - Nix development tools
{
  loss.dev._.nix.homeManager = {pkgs, ...}: {
    home.packages = [
      pkgs.nixd
      pkgs.nix-output-monitor
    ];
  };
}
