{
  description = "A personal Nix configuration for NixOS and Home Manager.";

  inputs = {
    # Core package set from the unstable channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager for user-level package management.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS on WSL integration module.
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    # Non-flake input for sourcing dotfiles.
    dotfiles = {
      url = "github:lossthannothing/.dotfiles/master";
      flake = false;
    };

    # --- Darwin Placeholder ---
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, nixos-wsl, ... }@inputs:
    let
      # A common set of Home Manager modules to be reused across configurations.
      homeModules = [
        ./home/home.nix
        ./home/code.nix
        ./home/shell.nix
      ];

      # Common special arguments passed to all modules.
      specialArgs = { inherit dotfiles; };

    in {
      # Standalone Home Manager configurations for non-NixOS systems (e.g., Ubuntu).
      # These can be activated using `home-manager switch --flake .#<name>`.
      homeConfigurations = {
        # For aarch64 Linux systems.
        "linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-linux;
          modules = homeModules;
          extraSpecialArgs = specialArgs;
        };

        # For x86_64 Linux systems.
        "x86_64-linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = homeModules;
          extraSpecialArgs = specialArgs;
        };

        # --- Darwin Placeholder ---
        # Uncomment to enable standalone Home Manager for macOS.
        # "darwin" = home-manager.lib.homeManagerConfiguration {
        #   pkgs = nixpkgs.legacyPackages.x86_64-darwin;
        #   # Note: macOS might require a different set of home modules.
        #   modules = homeModules;
        #   extraSpecialArgs = specialArgs;
        # };
      };

      # NixOS system configurations.
      # These are built using `nixos-rebuild switch --flake .#<name>`.
      nixosConfigurations = {
        "LossNixOS-WSL" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = specialArgs;
          modules = [
            # Core NixOS-WSL integration.
            nixos-wsl.nixosModules.default

            # Custom system-level modules.
            ./os/nixos.nix
            ./os/wsl.nix

            # Home Manager integration as a NixOS module.
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.loss = { imports = homeModules; };
            }
          ];
        };
      };

      # --- Darwin Placeholder ---
    };
}
