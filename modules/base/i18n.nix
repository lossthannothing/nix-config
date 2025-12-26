# modules/base/i18n.nix
#
# 国际化配置
{
  flake.modules.nixos.base = {
    i18n.defaultLocale = "zh_CN.UTF-8";
  };
}
