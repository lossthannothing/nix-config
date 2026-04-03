# modules/default.nix
#
# den.default - Global defaults applied to all hosts/users
# Contains: home-manager integration, basic shell, service management
{inputs, __findFile, ...}: let
  stateVersion = "25.11";
in {
  den.default = {
    includes = [
      <den/home-manager>
      <den/define-user>
      <loss/system>
      ({host, ...}: {
        ${host.class}.networking.hostName = host.name;
      })
    ];

    nixos = {pkgs, ...}: {
      # Shell defaults
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.enable = true;

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
    };
  };
}
