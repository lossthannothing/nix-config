# modules/system/wsl.nix
#
# loss.system._.wsl - WSL system configuration
# NixOS: WSL kernel, interop, nix-ld
{inputs, ...}: {
  loss.system._.wsl = {
    nixos = _: {
      imports = [inputs.nixos-wsl.nixosModules.default];

      wsl = {
        enable = true;
        wslConf.automount.root = "/mnt";
        wslConf.interop.appendWindowsPath = false;
      };

      programs.nix-ld.enable = true;
    };
  };
}
