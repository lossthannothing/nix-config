# modules/base/i18n.nix
#
# Internationalization configuration
# 国际化配置 - 跨平台通用

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Timezone settings
  time.timeZone = "Asia/Shanghai";
  
  # Locale settings
  i18n.defaultLocale = "zh_CN.UTF-8";
}
