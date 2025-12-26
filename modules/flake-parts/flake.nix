# modules/flake-parts/flake.nix
#
# Flake 元数据定义
{lib, ...}: {
  options.flake.meta = lib.mkOption {
    type = with lib.types; lazyAttrsOf anything;
    description = "Flake metadata including user information";
  };

  config.flake.meta.uri = "github:lossthannothing/nix-config";
}
