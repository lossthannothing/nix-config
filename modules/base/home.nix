# modules/base/home.nix
#
# Home Manager 基础配置
{
  flake.modules.homeManager.base = {pkgs, ...}: {
    programs.home-manager.enable = true;
    # 添加基础工具包
    home.packages = with pkgs; [
      wget # 显式管理，确保跨发行版一致性
    ];
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
