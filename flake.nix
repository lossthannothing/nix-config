{
  description = "A personal Nix configuration for NixOS and Home Manager.";

  nixConfig = {
    extra-substituters = [
      "https://anyrun.cachix.org"
    ];
    extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    dotfiles = {
      url = "github:lossthannothing/.dotfiles/master";
      flake = false;
    };
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
      inherit (nixpkgs) lib;

      # Import our helper library
      mylib = import ./lib { inherit lib; };

      # Common variables
      vars = mylib.vars;

      # Common special arguments
      specialArgs = {
        inherit dotfiles mylib;
      };
    in
    {
      # Home Manager configurations
      homeConfigurations = {
        "loss" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home ];
          extraSpecialArgs = specialArgs;
        };
      };

      # NixOS system configurations
      nixosConfigurations = {
        "nixos-wsl" = mylib.nixosSystem {
          inherit inputs lib;
          system = "x86_64-linux";
          nixos-modules = [
            nixos-wsl.nixosModules.default
            ./hosts/wsl
          ];
          home-modules = [ 
            ./home/home.nix
            ./home/shell
            ./home/dev
            ./home/platforms/wsl.nix
          ];
          inherit specialArgs;
          myvars = vars;
        };
        
        "nixos-vm" = mylib.nixosSystem {
          inherit inputs lib;
          system = "x86_64-linux";
          nixos-modules = [
            ./hosts/nixos-vm
          ];
          home-modules = [ 
            ./home/home.nix
            ./home/shell
            ./home/dev
            ./home/desktop.nix
            ./home/platforms/vm.nix
          ];
          inherit specialArgs;
          myvars = vars;
        };
      };
    };
}
