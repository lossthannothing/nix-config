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
        ./home/home.nix
        ./home/code.nix
        ./home/shell.nix
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
            ./os/nixos.nix
            ./os/wsl.nix
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
