# os/system-pkgs.nix
#
# System-level packages configuration
# 系统级软件包配置
{pkgs, ...}: {
  # System-level packages.
  # Only include core tools necessary for the system or all users.
  # User-specific tools (like Neovim, specific shells) should typically go in Home Manager.
  environment.systemPackages = with pkgs; [
    wget # A common utility, useful on most systems.
    htop # A process viewer.
    nixd # nix language server provider
    # Add other universally needed system packages here.
  ];
}
