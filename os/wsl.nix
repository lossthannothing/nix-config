# os/wsl.nix

{ config, pkgs, lib, ... }: # Ensure 'pkgs' and 'lib' are available in this module's scope

let
  # Meskill 提供的 bashWrapper 方案
  # 注意：这里需要 'lib' 来使用 'lib.makeBinPath'
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

  # Enable the core WSL integration provided by NixOS-WSL.
  wsl.enable = true;
  # Set the default user for the WSL instance. This is crucial for initial login.
  # It should match the user defined in ./os/nixos.nix.
  wsl.defaultUser = "loss"; # Ensure this matches the 'loss' user you're setting up.
  # sl netmode  mirrored
  # Override the general hostname for this specific WSL instance.
  networking.hostName = "nixos-wsl";

  # Disable bootloaders, as WSL handles booting differently and they are not needed.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = false;

  # --- Solution for VS Code Remote SSH on WSL: Using nix-ld ---
  # This enables nix-ld to provide compatibility for dynamically linked
  # foreign binaries (like the Node.js binary used by VS Code Remote Server).
  programs.nix-ld.enable = true;

  # --- Solution for Cursor Remote Server installation script (Meskill's advanced method) ---
  wsl = {
    wrapBinSh = true; # 启用 bash 包装器功能

    extraBin = [
      {
        name = "bash";
        src = "${bashWrapper}/bin/bash"; # 使用上面定义的定制 bash 包装器
      }
    ];
  };

  # 确保 wget (以及其他可能的依赖) 在系统包中
  environment.systemPackages = [
    pkgs.wget
  ];

  # You can add other WSL-specific configurations here if needed.
  # For example, if you have specific networking requirements for WSL that differ
  # from a general Linux setup.
}
