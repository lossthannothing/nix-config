# modules/base/default.nix
#
# 基础模块 - 同时包含 NixOS 和 Home Manager 的基础配置

{ pkgs, ... }:

{
  flake.modules = {
    # ========== NixOS 层基础配置 ==========
    nixos.base = { pkgs, lib, ... }: {
      # Nix 设置
      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          # 二进制缓存
          substituters = [
            # China mirrors
            "https://mirrors.ustc.edu.cn/nix-channels/store"
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            "https://nix-community.cachix.org"
          ];

          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          trusted-users = [
            "root"
            "loss"
          ];

          builders-use-substitutes = true;
        };
      };

      # 时区和语言环境
      time.timeZone = "Asia/Shanghai";
      i18n.defaultLocale = "zh_CN.UTF-8";

      # 允许非自由软件
      nixpkgs.config.allowUnfree = true;

      # 系统级软件包
      environment.systemPackages = with pkgs; [
        wget
        htop
        nixd
      ];
    };

    # ========== Home Manager 层基础配置 ==========
    homeManager.base = { config, ... }: {
      home = {
        username = "loss";
        homeDirectory = "/home/loss";
        stateVersion = "24.05";

        sessionVariables = {
          EDITOR = "nvim";
        };
      };

      # 让 Home Manager 管理自己
      programs.home-manager.enable = true;
    };
  };
}
