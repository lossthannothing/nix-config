# hosts/wsl/hardware.nix
#
# WSL hardware-specific configuration
# WSL 硬件特定配置
_: {
  # Host-specific configurations
  networking.hostName = "nixos-wsl";

  # System state version
  system.stateVersion = "24.05";
}
