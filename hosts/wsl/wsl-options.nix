# hosts/wsl/wsl-options.nix
#
# WSL host configuration
# WSL 主机配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # Import base OS configuration
    ../../os/base.nix
    # Import system packages
    ../../os/system-pkgs.nix
    # Import WSL platform configuration
    ../../os/platforms/wsl.nix
    # Import WSL platform packages
    ../../os/platforms/wsl-pkgs.nix
    # Import hardware configuration
    ./hardware.nix
  ];


}
