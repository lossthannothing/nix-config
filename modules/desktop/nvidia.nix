# modules/desktop/nvidia.nix
#
# NVIDIA proprietary driver for Wayland (Niri compositor)
# Modesetting + open kernel module for Blackwell (RTX 50 series)
{
  flake.modules.nixos.nvidia = {config, ...}: {
    # Load NVIDIA driver (required even on pure Wayland)
    services.xserver.videoDrivers = ["nvidia"];

    # NVIDIA driver settings
    hardware.nvidia = {
      modesetting.enable = true; # Required for Wayland compositors
      open = true; # Open kernel module (recommended for Turing+)
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # OpenGL / Vulkan
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Steam, Wine, etc.
    };

    # Wayland environment hints
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Electron apps use Wayland
    };
  };
}
