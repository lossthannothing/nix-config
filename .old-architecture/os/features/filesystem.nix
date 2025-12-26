# os/features/filesystem.nix
#
# Filesystem optimization configuration
# 文件系统优化配置
#
# This module provides:
# - Btrfs filesystem optimizations
# - Mount options for performance and reliability
# - Filesystem-specific tuning parameters
#
# 此模块提供：
# - Btrfs 文件系统优化
# - 用于性能和可靠性的挂载选项
# - 文件系统特定的调优参数
{
  pkgs,
  lib,
  ...
}:
{
  # Enable Btrfs support
  boot.supportedFilesystems = [ "btrfs" ];

  # System packages for filesystem management
  environment.systemPackages = with pkgs; [
    btrfs-progs # Btrfs utilities
  ];

  # Btrfs mount options for optimal performance
  # These options are commonly used for different filesystem layouts

  # Root filesystem options (performance + reliability balance)
  fileSystems."/" = lib.mkDefault {
    options = [
      "subvol=@root" # Use root subvolume
      "ssd" # Enable SSD optimizations
      "noatime" # Don't update access times (performance)
      "compress=zstd:3" # ZSTD compression level 3 (good balance)
      "autodefrag" # Automatic defragmentation
      "space_cache=v2" # Use space cache v2 for better performance
    ];
  };

  # Home directory options (prioritize compression for user data)
  fileSystems."/home" = lib.mkDefault {
    options = [
      "subvol=@home"
      "ssd"
      "noatime"
      "compress=zstd:3"
      "autodefrag"
      "space_cache=v2"
    ];
  };

  # Nix store options (optimized for read-heavy workloads)
  fileSystems."/nix" = lib.mkDefault {
    options = [
      "subvol=@nix"
      "ssd"
      "noatime"
      "compress=zstd:1" # Lower compression for faster decompression
      "space_cache=v2"
      # No autodefrag for nix store (mostly read-only)
    ];
  };

  # Optional: Additional Btrfs optimizations
  # These can be enabled based on specific hardware/use cases

  # services.btrfs.autoScrub = {
  #   enable = true;
  #   interval = "monthly";  # Regular filesystem checks
  # };

  # Boot-time filesystem optimizations
  boot.kernel.sysctl = {
    # Virtual memory optimizations for SSD
    "vm.swappiness" = lib.mkDefault 10; # Reduce swap usage
    "vm.dirty_ratio" = lib.mkDefault 15; # Start writeback earlier
    "vm.dirty_background_ratio" = lib.mkDefault 5; # Background writeback threshold
  };

  # Filesystem-specific kernel parameters
  boot.kernelParams = [
    # Enable transparent huge pages (can help with performance)
    "transparent_hugepage=madvise"
  ];
}
