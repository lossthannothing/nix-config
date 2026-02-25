# hosts/nixos-vm/default.nix
#
# NixOS VM with Niri compositor (lightweight desktop, no NVIDIA)
# For testing and VM deployment (QEMU/VirtualBox/VMware)
#
# Build: sudo nixos-rebuild switch --flake .#nixos-vm
# Build ISO: nix build .#nixosConfigurations.nixos-vm.config.system.build.images.iso
{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos."hosts/nixos-vm" = {...}: {
    imports = with config.flake.modules.nixos;
      [
        # External modules
        inputs.catppuccin.nixosModules.catppuccin

        # wired-notify overlay (provides pkgs.wired)
        {nixpkgs.overlays = [inputs.wired-notify.overlays.default];}

        # System modules (no nvidia, no facter for VM)
        base
        disko
        niri
        audio
        fonts
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

    # VM boot configuration
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Declarative disk layout: single virtual disk with btrfs subvolumes
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0022" "dmask=0022"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = ["noatime" "compress=zstd:3"];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["noatime" "compress-force=zstd:5"];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = ["noatime" "compress-force=zstd:1"];
                };
              };
            };
          };
        };
      };
    };

    # System identity
    networking.hostName = "nixos-vm";

    # Networking
    networking.networkmanager.enable = true;

    # VM-specific: enable guest additions
    virtualisation.vmVariant = {
      virtualisation = {
        memorySize = 4096;
        cores = 4;
      };
    };

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
