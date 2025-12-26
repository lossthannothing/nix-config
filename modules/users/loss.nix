# modules/users/loss.nix
#
# 用户 loss 的系统层定义

{ pkgs, ... }:

{
  flake.modules.nixos.loss = { pkgs, ... }: {
    # 定义用户
    users.users.loss = {
      isNormalUser = true;
      description = "Loss";
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
    };

    # 启用 zsh
    programs.zsh.enable = true;
  };
}
