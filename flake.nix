{
  description = "My personal NixOS/Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    # Home Manager should follow the nixpkgs version from this flake
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Your dotfiles repository, marked as a non-flake input
    dotfiles = {
      url = "github:lossthannothing/.dotfiles/master";
      flake = false;
    };

    # NixOS on WSL support module
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, nixos-wsl, ... }@inputs: {
    # Home Manager configurations
    # These configurations are defined independently and can be referenced by different system configurations.
    homeConfigurations = {
      # For AArch64 Linux (if you have an ARM-based Linux machine)
      linux = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [
          ./home/home.nix
          ./home/code.nix
          ./home/shell.nix
        ];
        extraSpecialArgs = { inherit dotfiles; };
      };
      # For x86_64 Linux (this is what your WSL instance will use)
      x86_64-linux = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home/home.nix
          ./home/code.nix
          ./home/shell.nix
        ];
        extraSpecialArgs = { inherit dotfiles; };
      };
    };

    # NixOS system configurations
    nixosConfigurations = {
      # Configuration for your NixOS on WSL instance
      # This name matches what you use in your nixos-rebuild command.
      "LossNixOS-WSL" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import the NixOS-WSL module, which handles core WSL integration.
          nixos-wsl.nixosModules.default

          # Import your general NixOS configuration (applies to any NixOS).
          ./os/nixos.nix

          # Import your WSL-specific system configuration.
          ./os/wsl.nix

          # Integrate Home Manager into this NixOS system configuration.
          home-manager.nixosModules.home-manager {
            home-manager.useUserPackages = true;
            # Use nixid to reference the x86_64-linux homeConfiguration defined in this flake.
            home-manager.users.loss = self.homeConfigurations.x86_64-linux;
          }
        ];
      };
    };
  };
}
