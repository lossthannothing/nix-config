# modules/base/home.nix
#
# Home Manager 基础配置
{
  flake.modules.homeManager.base = {
    programs.home-manager.enable = true;

    # See https://ohai.social/@rycee/112502545466617762
    # See https://github.com/nix-community/home-manager/issues/5452
    systemd.user.startServices = "sd-switch";

    services.home-manager.autoExpire = {
      enable = true;
      frequency = "weekly";
      store.cleanup = true;
    };
  };
}
