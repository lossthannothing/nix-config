# modules/flake-parts/flake-parts.nix
#
# 启用 flake-parts 模块系统
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
