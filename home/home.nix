# home/home.nix
#
# Basic Home Manager configuration
# 基础 Home Manager 配置

{ config, pkgs, ... }:

{
  # Basic home configuration
  home = {
    username = "loss";
    homeDirectory = "/home/loss";
    stateVersion = "24.05";
    
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
