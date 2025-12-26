# hosts/nixos-vm/user.nix
#
# User configuration for NixOS VM host
# NixOS 虚拟机主机的用户配置
{pkgs, ...}: {
  # Define the system user 'loss'. This username must match the one used in your
  # Home Manager configuration.
  users.users.loss = {
    isNormalUser = true;
    description = "loss";
    extraGroups = [
      "wheel" # sudo privileges
      "networkmanager"
      "audio"
      "video"
      "input"
    ];
    # Set the default shell for the user. Home Manager will provide detailed Zsh configuration.
    shell = pkgs.zsh;
  };

  # Enable Zsh as a system program.
  # This provides the Zsh executable; Home Manager will layer on top with dotfiles and plugins.
  programs.zsh.enable = true;

  # Enable NetworkManager for network management
  networking.networkmanager.enable = true;
}
