# modules/hosts/nixos-wsl/default.nix
#
# Host: nixos-wsl
# WSL2 NixOS instance — host-specific overrides only
{loss, ...}: {
  den.hosts.x86_64-linux.nixos-wsl = {};

  den.aspects.nixos-wsl = {
    includes = with loss; [
      wsl
      shell
      dev
      dev._.rust
      dev._.javascript
      dev._.go
      dev._.python
      dev._.nix
    ];

    nixos = {...}: {
      wsl.defaultUser = "loss";
      wsl.docker-desktop.enable = true;
      wsl.useWindowsDriver = true;
      nixpkgs.hostPlatform = "x86_64-linux";
    };
  };
}
