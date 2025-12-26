# hosts/wsl/wsl-options.nix
#
# WSL host configuration
# WSL 主机配置
{
  ...
}:
{
  imports = [
    # Import base OS configuration
    ../../os/base.nix
    # Import system packages
    ../../os/system-pkgs.nix
    # Import WSL spec configuration (migrated)
    ../../os/spec/wsl-distro.nix
    # Import WSL spec packages (migrated)
    ../../os/spec/wsl-pkgs.nix
    # Import hardware configuration
    ./hardware.nix
  ];
}
