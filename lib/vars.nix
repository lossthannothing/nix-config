# lib/vars.nix
#
# Common variables and configurations used across the project
# 项目中使用的通用变量和配置

{
  # User configuration
  username = "loss";

  # A common set of Home Manager modules to be reused across configurations.
  homeModules = [
    ../home/home.nix
    ../home/code.nix
    ../home/shell.nix
  ];
}
