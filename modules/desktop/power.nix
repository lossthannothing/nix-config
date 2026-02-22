# modules/desktop/power.nix
#
# Power management: power-profiles-daemon + UPower
{
  flake.modules.nixos.power = {
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
  };
}
