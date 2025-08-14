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
    flake-parts.url = "github:hercules-ci/flake-parts";
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

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # 支持的系统架构
      systems = [ "x86_64-linux" ];
      
      # 导入模块（可选，现在先保持所有配置在这里）
      imports = [ ];
      
      # 原有的 flake 属性
      flake =
        let
          inherit (inputs.nixpkgs) lib;
          
          # Import our helper library
          mylib = import ./lib { inherit lib; };
          
          # Common variables
          vars = mylib.vars;
          
          # Common special arguments
          specialArgs = {
            inherit (inputs) dotfiles;
            inherit mylib;
          };
        in
        {
          # Home Manager configurations
          homeConfigurations = {
            "loss" = inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
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
                inputs.nixos-wsl.nixosModules.default
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
      
      # 每个系统的配置
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # 可以在这里定义开发环境、包等
        # 现在暂时为空
      };
    };
}
