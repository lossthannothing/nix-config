{
  flake.modules = {
    # ============================================================
    # 注入到 nixos.base
    # ============================================================
    nixos.base = {pkgs, ...}: {
      nix = {
        channel.enable = false;
        nixPath = ["nixpkgs=${pkgs.path}"];

        extraOptions = ''
          connect-timeout = 5
          log-lines = 50
          min-free = 128000000
          max-free = 1000000000
          fallback = true
        '';
        optimise.automatic = true;

        settings = {
          trusted-users = ["root" "@wheel"];
          auto-optimise-store = true;
          experimental-features = ["nix-command" "flakes"];
          warn-dirty = false;
          tarball-ttl = 60 * 60 * 24;

          substituters = [
            "https://mirrors.ustc.edu.cn/nix-channels/store"
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            "https://mirrors.cernet.edu.cn/nix-channels/store"
            "https://mirror.sjtu.edu.cn/nix-channels/store"
            "https://mirrors.bfsu.edu.cn/nix-channels/store"
            "https://mirror.nju.edu.cn/nix-channels/store"
            "https://mirror.iscas.ac.cn/nix-channels/store"
            "https://nix-community.cachix.org"
            "https://cache.nixos.org/"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          builders-use-substitutes = true;
        };
      };
    };

    # ============================================================
    # 注入到 homeManager.base
    # ============================================================
    homeManager.base = {
      pkgs,
      lib,
      ...
    }: {
      nix = {
        # 【关键】Standalone 模式下必须显式安装 Nix 包，才能在 PATH 中找到 nix 命令
        package = lib.mkDefault pkgs.nix;

        settings = {
          experimental-features = ["nix-command" "flakes"];
          auto-optimise-store = true;
          warn-dirty = false;

          # HM Standalone 用户级缓存配置
          substituters = [
            "https://mirrors.ustc.edu.cn/nix-channels/store"
            "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
            "https://mirrors.cernet.edu.cn/nix-channels/store"
            "https://mirror.sjtu.edu.cn/nix-channels/store"
            "https://mirrors.bfsu.edu.cn/nix-channels/store"
            "https://mirror.nju.edu.cn/nix-channels/store"
            "https://mirror.iscas.ac.cn/nix-channels/store"
            "https://nix-community.cachix.org"
            "https://cache.nixos.org/"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
      };
    };
  };
}
