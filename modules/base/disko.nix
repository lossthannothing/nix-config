# modules/base/disko.nix
# Declarative disk partitioning — registers disko NixOS module
# Host imports list: add `disko` to use disko.devices options
{inputs, ...}: {
  flake.modules.nixos.disko = {
    imports = [inputs.disko.nixosModules.disko];
  };
}
