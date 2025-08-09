# os/platform-spec/wsl-distro.nix
#
# WSL-specific NixOS configuration
# WSL 特定的 NixOS 配置

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Meskill 提供的 bashWrapper 方案 用于处理cursor
  bashWrapper =
    with pkgs;
    runCommand "nixos-wsl-bash-wrapper"
      {
        nativeBuildInputs = [ makeWrapper ];
      }
      ''
        makeWrapper ${bashInteractive}/bin/bash $out/bin/bash \
          --prefix PATH ':' ${
            lib.makeBinPath ([
              systemd
              gnugrep
              coreutils
              gnutar
              gzip
              getconf
              gnused
              procps
              which
              gawk
              wget
              curl
              util-linux
            ])
          }
      '';
in
{
  # --------------------------------------------------------------------
  # WSL-Specific System Configuration
  # --------------------------------------------------------------------

  # 将所有 wsl 配置合并到一个块中
  wsl = {
    enable = true; # 启用 NixOS-WSL 核心功能
    defaultUser = "loss"; # 设置默认用户
    wrapBinSh = true; # 启用 bash 包装器功能
    useWindowsDriver = true;
    startMenuLaunchers = true; # 在开始菜单中创建Linux gui app
    # usbip = {
    #   enable = true;
    #   # Tell usbip to connect to the Windows host via the loopback address.
    #   snippetIpAddress = "127.0.0.1";
    # };
    docker-desktop.enable = true;
    # 为 Cursor 添加 bash
    # extraBin = [
    #   {
    #     name = "bash";
    #     src = "${bashWrapper}/bin/bash";
    #   }
    # ];
    # 从 os/platforms/wsl.nix 合并的 wslConf 设置
    wslConf.automount.root = "/mnt";
    # interop.includePath = true;
    wslConf.interop.appendWindowsPath = true;
    # wslConf.network.generateHosts = false;
  };

  # Note: hostname is now set in hosts/nixos-wsl/default.nix
  # networking.hostName is host-specific, not WSL-specific

  # Disable bootloaders, as WSL handles booting differently and they are not needed.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = false;

  # 关闭在 WSL 下不需要/不可用的 systemd 服务（来自 os/platforms/wsl.nix）
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-networkd.enable = false;

  # WSL 的网络配置（来自 os/platforms/wsl.nix）
  # networking = {
  #   dhcpcd.enable = false;
  #   useDHCP = false;
  #   useNetworkd = false;
  # };

  # --- Solution for VS Code Remote SSH on WSL: Using nix-ld ---
  programs.nix-ld.enable = true;

}

