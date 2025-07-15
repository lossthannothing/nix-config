{
  description = "My personal NixOS/Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    # Home Manager should follow the nixpkgs version from this flake
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nix-darwin for macOS system configuration management
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles = {
      url = "github:lossthannothing/.dotfiles/master";
      flake = false;
    };

    # NixOS on WSL support module
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, nix-darwin, nixos-wsl, ... }@inputs: {
    # Home Manager configurations
    # These configurations are defined independently and can be referenced by different system configurations.
    homeConfigurations = {
      linux = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [
          ./home/home.nix
          ./home/code.nix
          ./home/shell.nix
        ];
        extraSpecialArgs = { inherit dotfiles; };
      };
      x86_64-linux = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home/home.nix
          ./home/code.nix
          ./home/shell.nix
        ];
        extraSpecialArgs = { inherit dotfiles; };
      };
      darwin = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          ./home/home-mac.nix
          ./home/code.nix
          ./home/shell.nix
        ];
        extraSpecialArgs = { inherit dotfiles; };
      };
    };

    # NixOS system configurations
    nixosConfigurations = {
      # Configuration for NixOS on WSL
      # Named 'nixos' for simplicity and general applicability within the flake.
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Import the NixOS-WSL module to handle most WSL-specific integrations.
          nixos-wsl.nixosModules.default

          # Import your general NixOS configuration.
          ./os/nixos.nix

          # --- WSL-specific configurations that are not general ---
          {
            # Enable WSL functionality.
            wsl.enable = true;
            # Set the default user for WSL; ensure this matches the user defined in ./os/nixos.nix.
            wsl.defaultUser = "loss";
            # Set the hostname specifically for the WSL instance, overriding any general setting.
            networking.hostName = "nixos-wsl";

            # Disable bootloaders, as they are not needed in WSL.
            boot.loader.systemd-boot.enable = false;
            boot.loader.grub.enable = false;

            # --- Solution for VS Code Remote SSH on WSL: using nix-ld ---
            programs.nix-ld.enable = true;

            # Ensure wget is installed on the WSL system.
            # It's a general utility, but explicitly ensured here for the WSL context if not in os/nixos.nix.
            environment.systemPackages = with pkgs; [
              wget
            ];
          }

          # --- Home Manager integration into the NixOS system configuration ---
          home-manager.nixosModules.home-manager {
            # Ensure user packages take precedence over system packages.
            home-manager.useUserPackages = true;
            # Specify the Home Manager configuration for the 'loss' user.
            # Using the nixid convention to reference the homeConfiguration defined within this flake.
            home-manager.users.loss = self.homeConfigurations.x86_64-linux;
          }
        ];
      };
    };

    # darwin system configuration (for macOS)
    darwinConfigurations."MAC" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # Ensure this is the correct Darwin architecture.
      modules = [
        # Import your Darwin-specific system configuration.
        ./os/darwin.nix
      ];
    };
  };
}
