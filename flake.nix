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

    # 新增：架构工具
    import-tree.url = "github:vic/import-tree";

    # 新增：硬件配置简化
    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 新增：自定义包管理简化
    pkgs-by-name-for-flake-parts = {
      url = "github:drupol/pkgs-by-name-for-flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        # 启用 flake-parts 模块系统
        flake-parts.flakeModules.modules

        # 启用自定义包管理（可选）
        # inputs.pkgs-by-name-for-flake-parts.flakeModule

        # 核心生成器
        ./modules/flake-parts/host-machines.nix

        # 用户模块
        ./modules/users/loss.nix

        # 基础模块
        ./modules/base/default.nix

        # Shell 模块
        ./modules/shell/bat.nix
        ./modules/shell/zoxide.nix
        ./modules/shell/fzf.nix
        ./modules/shell/lsd.nix
        ./modules/shell/fd.nix
        ./modules/shell/sheldon.nix
        ./modules/shell/cli-tools.nix
        ./modules/shell/zsh.nix

        # Dev 模块
        ./modules/dev/git.nix
        ./modules/dev/dev-tools.nix

        # Hosts
        ./hosts/wsl/default.nix
      ];
    };
}
