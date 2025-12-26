# os/features/boot.nix
#
# Boot configuration and optimization
# 启动配置和优化
#
# This module provides:
# - Bootloader configuration (systemd-boot)
# - Kernel selection and optimization
# - Boot-time performance tuning
#
# 此模块提供：
# - 引导程序配置 (systemd-boot)
# - 内核选择和优化
# - 启动时性能调优
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Bootloader configuration
  boot.loader = {
    systemd-boot = {
      enable = lib.mkDefault true;
      # Limit the number of generations shown in the boot menu
      configurationLimit = lib.mkDefault 10;
      # Enable editor for boot entries (useful for recovery)
      editor = lib.mkDefault false; # Set to true if you need boot parameter editing
    };

    efi = {
      canTouchEfiVariables = lib.mkDefault true;
      # EFI boot partition size optimization
      efiSysMountPoint = lib.mkDefault "/boot";
    };

    # Reduce timeout for faster boot
    timeout = lib.mkDefault 3; # 3 seconds boot menu timeout
  };

  # Kernel selection and configuration
  boot = {
    # Use latest kernel for better hardware support and performance
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # Essential kernel modules
    kernelModules = [
      "tun" # VPN support
    ];

    # Kernel parameters for optimization
    kernelParams = [
      # Reduce boot time
      "quiet" # Suppress verbose boot messages
      "loglevel=3" # Reduce kernel log verbosity
      "udev.log_level=3" # Reduce udev log verbosity

      # Security enhancements
      "slab_nomerge" # Prevent slab merging (security)
      "init_on_alloc=1" # Initialize memory on allocation
      "init_on_free=1" # Initialize memory on free

      # Performance optimizations
      "mitigations=auto" # Enable CPU vulnerability mitigations
      "nowatchdog" # Disable hardware watchdog (can cause issues)
    ];

    # Kernel modules to load during early boot
    initrd = {
      availableKernelModules = [
        "nvme" # NVMe SSD support
        "ehci_pci" # USB 2.0 support
        "xhci_pci" # USB 3.0 support
        "xhci_pci_renesas" # Renesas USB 3.0 controllers
        "usbhid" # USB HID devices
        "usb_storage" # USB storage devices
        "sd_mod" # SCSI disk support
        "rtsx_pci_sdmmc" # Realtek card reader support
      ];

      # Compression for initrd (faster boot)
      compressor = lib.mkDefault "zstd";
    };

    # Enable Intel/AMD microcode updates
    # This will be overridden by hardware-specific configurations
    # kernelModules = [ "kvm-intel" ]; # or "kvm-amd" for AMD
  };

  # System optimization settings
  boot.kernel.sysctl = {
    # Network optimizations
    "net.core.rmem_default" = lib.mkDefault 262144;
    "net.core.rmem_max" = lib.mkDefault 16777216;
    "net.core.wmem_default" = lib.mkDefault 262144;
    "net.core.wmem_max" = lib.mkDefault 16777216;

    # File system optimizations
    "fs.file-max" = lib.mkDefault 65536;
    "fs.inotify.max_user_watches" = lib.mkDefault 524288;

    # Performance optimizations
    "kernel.sched_migration_cost_ns" = lib.mkDefault 5000000; # Reduce CPU migration cost
  };

  # Boot-time services optimization
  systemd = {
    # Reduce systemd service timeouts for faster shutdown/reboot
    extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=10s
    '';

    # Enable systemd-resolved for faster DNS resolution
    services."systemd-resolved".wantedBy = [ "multi-user.target" ];
  };

  # Early boot optimizations
  boot.plymouth.enable = lib.mkDefault false; # Disable boot splash for faster boot

  # Hardware-specific CPU optimizations (to be overridden by hardware configs)
  # This provides a sensible default
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
