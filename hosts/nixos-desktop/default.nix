# hosts/nixos-desktop/default.nix
#
# NixOS desktop with Niri compositor (NVIDIA Blackwell)
# Hardware auto-detected from facter.json
#
# Build ISO (nixpkgs built-in image system):
#   nix build .#nixosConfigurations.nixos-desktop.config.system.build.images.iso
{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos."hosts/nixos-desktop" = {...}: {
    imports = with config.flake.modules.nixos;
      [
        # Hardware detection from facter.json (kernel modules, firmware)
        {hardware.facter.reportPath = ./facter.json;}

        # External modules
        inputs.catppuccin.nixosModules.catppuccin

        # wired-notify overlay (provides pkgs.wired)
        {nixpkgs.overlays = [inputs.wired-notify.overlays.default];}

        # System modules
        base
        facter
        fonts
        nvidia
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
              inputs.wired-notify.homeManagerModules.default
              base
              shell
              dev
              desktop
              loss
            ];
          };
        }
      ];

    # Target disk layout (UEFI + btrfs)
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = ["subvol=@" "compress=zstd"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

    # System identity
    networking.hostName = "nixos-desktop";

    # Networking
    networking.networkmanager.enable = true;

    # Auto-login to Niri compositor via greetd
    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "niri-session";
        user = "loss";
      };
    };
  };
}
