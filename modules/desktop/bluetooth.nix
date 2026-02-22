# modules/desktop/bluetooth.nix
#
# Bluetooth support with Blueman GUI manager
{
  flake.modules.nixos.bluetooth = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
