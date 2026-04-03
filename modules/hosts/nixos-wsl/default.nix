# modules/hosts/nixos-wsl/default.nix
#
# Host: nixos-wsl
# WSL2 NixOS instance — host-specific overrides only
{loss, ...}: {
  den.hosts.x86_64-linux.nixos-wsl = {};

  den.aspects.nixos-wsl = {
    includes = with loss; [
      system._.wsl        # WSL system config
      profiles.wsl        # WSL user preferences
      shell               # Terminal ecosystem (aggregation)
      dev._.tools         # Dev utilities (direnv, ripgrep, etc.)
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
