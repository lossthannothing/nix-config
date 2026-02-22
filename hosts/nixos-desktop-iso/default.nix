# hosts/nixos-desktop-iso/default.nix
#
# Minimal NixOS installer ISO with CN proxy & mirrors
# Build: nix build .#nixosConfigurations.nixos-desktop-iso.config.system.build.isoImage
{
  config,
  inputs,
  ...
}: {
  flake.modules.nixos."hosts/nixos-desktop-iso" = {
    pkgs,
    lib,
    ...
  }: {
    imports = with config.flake.modules.nixos; [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      base
    ];

    # CN proxy (same pattern as scripts/proxy-wrapper.sh)
    networking.proxy = {
      httpProxy = "http://127.0.0.1:7890";
      httpsProxy = "http://127.0.0.1:7890";
      noProxy = "localhost,127.0.0.1,::1";
    };

    # CN nix mirrors
    nix.settings.substituters = lib.mkForce [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];

    # Bootstrap tools for cloning repo and installing
    environment.systemPackages = with pkgs; [
      git
      vim
      wget
      curl
      nixos-facter
    ];

    # Enable SSH for remote install
    services.openssh.enable = true;
  };
}
