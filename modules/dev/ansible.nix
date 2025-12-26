# modules/dev/ansible.nix
#
# Ansible 自动化工具
{
  flake.modules = {
    homeManager.dev = {pkgs, ...}: {
      home.packages = with pkgs; [ansible];
    };
  };
}
