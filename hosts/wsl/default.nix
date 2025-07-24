# hosts/wsl/default.nix
#
# WSL host configuration entry point
# WSL 主机配置入口点

{
  imports = [
    ./wsl-options.nix
    ./user.nix
  ];
}
