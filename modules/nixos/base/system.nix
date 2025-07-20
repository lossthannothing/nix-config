# modules/nixos/base/system.nix
#
# NixOS system configuration
# NixOS 系统配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # System state version; important for upgrades and compatibility.
  # Ensure this matches your actual NixOS version (e.g., "24.05" or "25.05").
  system.stateVersion = "25.05"; # Updated to 25.05 as per your README's rebuild command

  # System-level packages.
  # Only include core tools necessary for the system or all users.
  # User-specific tools (like Neovim, specific shells) should typically go in Home Manager.
  environment.systemPackages = with pkgs; [
    wget # A common utility, useful on most systems.
    htop # A process viewer.
    # Add other universally needed system packages here.
  ];
}
