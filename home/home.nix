{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";
  home.username = "loss";
  home.homeDirectory = "/home/loss";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # 需要安装的包
  home.packages = with pkgs; [
    home-manager
  ];

  # Nixpkgs 相关配置
  nixpkgs.config.allowUnfree = true;
}
