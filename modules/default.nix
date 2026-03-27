# modules/default.nix
#
# den.default - Global defaults applied to all hosts/users
# Merged from: base/nix.nix, base/i18n.nix, base/system/, base/time/, base/console/, base/home.nix
{inputs, __findFile, ...}: let
  # Shared configuration constants
  stateVersion = "25.11";

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

  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
in {
  den.default = {
    includes = [
      <den/home-manager>
      <den/define-user>
      ({host, ...}: {
        ${host.class}.networking.hostName = host.name;
      })
    ];

    nixos = {pkgs, ...}: {
      nixpkgs.config.allowUnfree = true;

      # Shell defaults
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.enable = true;
      console = {
        earlySetup = true;
        useXkbConfig = true;
      };

      # Nix daemon configuration
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
          inherit substituters trusted-public-keys;
          builders-use-substitutes = true;
        };
      };

      # Locale & timezone
      i18n.defaultLocale = "zh_CN.UTF-8";
      time.timeZone = "Asia/Shanghai";

      # State version
      system.stateVersion = stateVersion;

      # Home Manager integration
      home-manager.useGlobalPkgs = false;
      home-manager.useUserPackages = true;
    };

    homeManager = {pkgs, lib, ...}: {
      programs.home-manager.enable = true;
      programs.zsh.enable = true;

      home = {
        inherit stateVersion;
        packages = with pkgs; [wget];
      };

      # sd-switch for service management
      systemd.user.startServices = "sd-switch";

      services.home-manager.autoExpire = {
        enable = true;
        frequency = "weekly";
        store.cleanup = true;
      };

      # Nix settings for standalone HM
      nix = {
        package = lib.mkDefault pkgs.nix;
        settings = {
          experimental-features = ["nix-command" "flakes"];
          auto-optimise-store = true;
          warn-dirty = false;
          inherit substituters trusted-public-keys;
        };
      };
    };
  };
}
