# modules/base/nix.nix
#
# Nix package manager configuration
# Nix 包管理器配置 - 跨平台通用

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable Nix Flakes features (a good global setting for flakes-based configurations).
  nix = {
    # Nix settings are grouped here.
    settings = {
      # This line you already have.
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # substituers that will be considered before the official ones(https://cache.nixos.org)
      substituters = [
        # cache mirror located in China
        # status: https://mirrors.ustc.edu.cn/status/
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        # status: https://mirror.sjtu.edu.cn/
        # "https://mirror.sjtu.edu.cn/nix-channels/store"
        # others
        # "https://mirrors.sustech.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

        "https://nix-community.cachix.org"
        # my own cache server, currently not used.
        # "https://ryan4yin.cachix.org"
      ];

      # 公钥用于验证二进制缓存
      trusted-public-keys = [
        # 官方缓存是默认打开的，不用添加
        # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "ryan4yin.cachix.org-1:Gbk27ZU5AYpGS9i3ssoLlwdvMIh0NxG0w8it/cv9kbU="
      ];
      builders-use-substitutes = true;
    };
  };
}
