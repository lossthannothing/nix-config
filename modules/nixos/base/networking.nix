# modules/nixos/base/networking.nix
#
# NixOS networking configuration
# NixOS 网络配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Network configuration will be added here
  # 网络配置将在此处添加
  
  # Example configurations (commented out):
  # networking.firewall.allowedTCPPorts = [ ... ];
  # services.avahi.enable = true;
  # networking.timeServers = [ ... ];
}
