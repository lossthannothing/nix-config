# modules/base/facter.nix
#
# nixos-facter - hardware detection replacing hardware-configuration.nix
# Each host overrides hardware.facter.reportPath to its own facter.json
# Generate: sudo nix run nixpkgs#nixos-facter -- -o <path>/facter.json
{
  flake.modules.nixos.facter = {pkgs, ...}: {
    environment.systemPackages = [pkgs.nixos-facter];
  };
}
