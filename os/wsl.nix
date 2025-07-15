# os/wsl.nix

{ config, pkgs, lib, ... }:

let
  # Meskill 提供的 bashWrapper 方案
  bashWrapper = with pkgs;
    runCommand "nixos-wsl-bash-wrapper"
      {
        nativeBuildInputs = [ makeWrapper ];
      } ''
      makeWrapper ${bashInteractive}/bin/bash $out/bin/bash \
        --prefix PATH ':' ${lib.makeBinPath ([ systemd gnugrep coreutils gnutar gzip getconf gnused procps which gawk wget curl util-linux ])}
    '';
in
{
  # --------------------------------------------------------------------
  # WSL-Specific System Configuration
  # --------------------------------------------------------------------

  # 将所有 wsl 配置合并到一个块中
  wsl = {
    enable = true;          # 启用 NixOS-WSL 核心功能
    defaultUser = "loss";   # 设置默认用户
    wrapBinSh = true;       # 启用 bash 包装器功能

    # 为 Cursor 添加 bash
    extraBin = [
      {
        name = "bash";
        src = "${bashWrapper}/bin/bash";
      }
    ];
  };

  # Override the general hostname for this specific WSL instance.
  networking.hostName = "nixos-wsl";

  # Disable bootloaders, as WSL handles booting differently and they are not needed.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = false;

  # --- Solution for VS Code Remote SSH on WSL: Using nix-ld ---
  programs.nix-ld.enable = true;

  # 确保 wget (以及其他可能的依赖) 在系统包中
  environment.systemPackages = [
    pkgs.wget
  ];
}
