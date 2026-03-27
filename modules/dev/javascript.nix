# modules/dev/javascript.nix
#
# loss.dev._.javascript - JavaScript/TypeScript development
{
  loss.dev._.javascript.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      fnm
      deno
    ];
    programs.bun.enable = true;
  };
}
