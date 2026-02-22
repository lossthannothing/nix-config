# hosts/nixos-desktop/default.nix
#
# Full NixOS desktop with Niri compositor
# Hardware via nixos-facter (facter.json), not hardware-configuration.nix
{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos."hosts/nixos-desktop" = {...}: {
    imports = with config.flake.modules.nixos;
      [
        # Hardware detection (replaces hardware-configuration.nix)
        {hardware.facter.reportPath = ./facter.json;}

        # External modules
        inputs.catppuccin.nixosModules.catppuccin

        # System modules
        base
        facter
        fonts
        niri
        audio
        bluetooth
        power
        fcitx5
        swaylock

        # User
        loss
      ]
      ++ [
        # Home Manager integration
        {
          home-manager.users.loss = {
            imports = with config.flake.modules.homeManager; [
              inputs.catppuccin.homeModules.catppuccin
              base
              shell
              dev
              desktop
              loss
            ];
          };
        }
      ];
  };
}
