{
  description = "A personal Nix configuration for NixOS and Home Manager.";
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://anyrun.cachix.org"
      # "https://nix-gaming.cachix.org"
      # "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      # "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };
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

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      dotfiles,
      nixos-wsl,
      ...
    }@inputs:
    let
      # User configuration
      username = "loss";

      # A common set of Home Manager modules to be reused across configurations.
      homeModules = [
        ./home
      ];

      # Common special arguments passed to all modules.
      specialArgs = { inherit dotfiles; };

      # Helper function to create Home Manager configurations
      mkHomeConfig =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = homeModules;
          extraSpecialArgs = specialArgs;
        };

    in
    {
      # Standalone Home Manager configurations
      homeConfigurations = {
        # Primary configurations: username@architecture
        "${username}@x86_64-linux" = mkHomeConfig "x86_64-linux";
        "${username}@aarch64-linux" = mkHomeConfig "aarch64-linux";
        "${username}@x86_64-darwin" = mkHomeConfig "x86_64-darwin";
        "${username}@aarch64-darwin" = mkHomeConfig "aarch64-darwin";

        # 智能默认：自动检测当前系统架构
        "${username}" = mkHomeConfig (builtins.currentSystem or "x86_64-linux");

        # Backward compatibility aliases
        "x86_64-linux" = mkHomeConfig "x86_64-linux";
        "linux" = mkHomeConfig "aarch64-linux";

        # --- Darwin Placeholder ---
      };

      # NixOS system configurations - 按主机名命名
      nixosConfigurations = {
        # 与 networking.hostName 保持一致
        "nixos-wsl" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = specialArgs;
          modules = [
            nixos-wsl.nixosModules.default
            ./hosts/nixos-wsl
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${username} = {
                imports = homeModules;
              };
            }
          ];
        };

        # 如果有其他系统，按主机名命名
        # "desktop" = nixpkgs.lib.nixosSystem { ... };
        # "laptop" = nixpkgs.lib.nixosSystem { ... };
      };

      # --- Darwin Placeholder ---
    };
}
