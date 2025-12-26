# modules/base/time/default.nix
#
# 时区配置
{
  flake.modules.nixos.base = {
    time.timeZone = "Asia/Shanghai";
  };
}
