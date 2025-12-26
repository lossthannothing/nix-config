# hosts/nixos-vm/hardware.nix
#
# A module for VM-specific hardware configuration, designed to be composed
# with a generated hardware configuration.
# 虚拟机硬件配置模块，旨在与自动生成的硬件配置组合使用。
_: {
  # Define file systems based on their mount points.
  # These definitions will be merged with the generated hardware-configuration.nix.
  # 基于挂载点定义文件系统。这些定义将与生成的 hardware-configuration.nix 合并。

  fileSystems."/" = {
    # The device and fsType are typically provided by the generated hardware.nix.
    # We are adding the Btrfs subvolume options here.
    # 设备和文件系统类型通常由生成的 hardware.nix 提供。我们在此处添加 Btrfs 子卷选项。
    options = [
      "subvol=@root"
      "ssd"
      "noatime"
      "compress=zstd:3"
      "autodefrag"
    ];
  };

  fileSystems."/home" = {
    options = [
      "subvol=@home"
      "ssd"
      "noatime"
      "compress=zstd:3"
      "autodefrag"
    ];
  };

  fileSystems."/nix" = {
    options = [
      "subvol=@nix"
      "ssd"
      "noatime"
      "compress=zstd:3"
    ];
  };
}
