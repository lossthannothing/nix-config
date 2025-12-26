# home/dev/ide.nix
#
# IDE configuration module
# IDE 配置模块
#
# This module contains IDE-specific configurations
{pkgs, ...}: {
  # IDE packages
  home.packages = with pkgs; [
    # Add IDE packages here when needed
    # vscode
    # jetbrains.idea-ultimate
  ];

  # IDE-related configurations
  # Add IDE-specific configurations here
}
