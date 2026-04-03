# modules/system/locale.nix
#
# loss.system._.locale — i18n, timezone, console, stateVersion
let
  stateVersion = "25.11";
in {
  loss.system._.locale.nixos = {...}: {
    i18n.defaultLocale = "zh_CN.UTF-8";
    time.timeZone = "Asia/Shanghai";

    console = {
      earlySetup = true;
      useXkbConfig = true;
    };

    system.stateVersion = stateVersion;
  };
}
