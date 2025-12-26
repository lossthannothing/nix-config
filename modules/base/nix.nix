# modules/base/nix.nix
#
# Nix 核心配置
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      nix = {
        # 禁用传统 channel，使用 flake
        # See https://discourse.nixos.org/t/24-05-add-flake-to-nix-path/46310/9
        channel.enable = false;
        nixPath = [ "nixpkgs=${pkgs.path}" ];

        # 性能优化
        # From https://jackson.dev/post/nix-reasonable-defaults/
        extraOptions = ''
          connect-timeout = 5
          log-lines = 50
          min-free = 128000000
          max-free = 1000000000
          fallback = true
        '';
        optimise.automatic = true;

        settings = {
          # 基础 trusted-users，各用户模块会添加自己
          trusted-users = [ "root" ];

          auto-optimise-store = true;

          experimental-features = [
            "nix-command"
            "flakes"
          ];

          warn-dirty = false;
          tarball-ttl = 60 * 60 * 24;

          # 二进制缓存
          substituters = [
            # China mirrors
            "https://mirrors.ustc.edu.cn/nix-channels/store"
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            "https://nix-community.cachix.org"
          ];

          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          builders-use-substitutes = true;
        };
      };
    };
}
