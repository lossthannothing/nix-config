# os/configuration.nix
#
# NixOS core configuration - Base entry for all NixOS systems
# NixOS 核心配置 - 所有 NixOS 系统的基础入口
{...}: {
  imports = [
    # Core system modules (explicit import to avoid platform conflicts)
    ./system-pkgs.nix
    # Platform-specific modules are imported by hosts
    # ./wsl.nix      # Imported by WSL hosts
    # ./darwin.nix   # Imported by Darwin hosts
  ];

  # Enable Nix Flakes features
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Binary cache substituters
      substituters = [
        # China mirrors
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
      ];

      # Public keys for binary cache verification
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      # Trusted users who can override nix settings
      trusted-users = [
        "root"
        "loss"
      ];

      builders-use-substitutes = true;
    };
  };

  # Timezone and locale settings
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
