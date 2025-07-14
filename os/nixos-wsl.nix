# os/nixos-wsl.nix

{ config, pkgs, ... }:

{
  # --------------------------------------------------------------------
  # 1. 系统级配置 (System Level Configuration)
  # --------------------------------------------------------------------

  # WSL 集成
  wsl.enable = true;
  wsl.defaultUser = "loss"; # 确保与您的用户名匹配

  # 禁用引导加载程序 (WSL不需要)
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = false;

  # 网络和时区
  networking.hostName = "nixos-wsl";
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  # Nix Flakes 功能
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.05";

  # 系统级软件包
  # 注意：只在这里放系统管理员或所有用户都需要的核心工具。
  # 不要在这里放 neovim, zsh 等，因为 Home Manager 会为您的用户安装它们。
  environment.systemPackages = with pkgs; [
    wget
    htop
    home-manager
  ];

  # --------------------------------------------------------------------
  # 2. 用户和 Home Manager 集成 (User & Home Manager Integration)
  # --------------------------------------------------------------------

  # 创建一个系统用户 "loss"。这必须和您 home.nix 中的用户名完全一致。
  users.users.loss = {
    isNormalUser = true;
    description = "loss";
    extraGroups = [ "wheel" ]; # `wheel` 组提供 sudo 权限
    # 设置默认 Shell。Home Manager 之后会为 zsh 注入详细配置。
    shell = pkgs.zsh;
  };

}