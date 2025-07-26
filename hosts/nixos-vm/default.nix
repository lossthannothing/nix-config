# hosts/nixos-vm/default.nix
#
# NixOS VM host configuration entry point
# NixOS 虚拟机主机配置入口点

{
  imports = [
    ./vm-options.nix
    ./user.nix
  ];
}