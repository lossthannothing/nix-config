# home/default.nix
#
# Home Manager configuration entry point
# Home Manager 配置入口点
{...}: {
  imports = [
    ./home.nix
    ./dev
    ./shell
  ];
}
