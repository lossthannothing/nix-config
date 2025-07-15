# os/nixos.nix

{ config, pkgs, lib, ... }:

{
  # --------------------------------------------------------------------
  # General System Level Configuration
  # --------------------------------------------------------------------

  # Enable Nix Flakes features (a good global setting for flakes-based configurations).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # System state version; important for upgrades and compatibility.
  # Ensure this matches your actual NixOS version (e.g., "24.05" or "25.05").
  system.stateVersion = "25.05"; # Updated to 25.05 as per your README's rebuild command

  # Networking and timezone settings. These are general defaults that can be
  # overridden by more specific configurations (like in os/wsl.nix or flake.nix).
  networking.hostName = lib.mkDefault "nixos"; # A generic hostname for any NixOS instance.
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  # System-level packages.
  # Only include core tools necessary for the system or all users.
  # User-specific tools (like Neovim, specific shells) should typically go in Home Manager.
  environment.systemPackages = with pkgs; [
    wget # A common utility, useful on most systems.
    htop # A process viewer.
    # Add other universally needed system packages here.
  ];

  # --------------------------------------------------------------------
  # User and Shell Configuration
  # --------------------------------------------------------------------

  # Define the system user 'loss'. This username must match the one used in your
  # Home Manager configuration and the 'wsl.defaultUser' setting.
  users.users.loss = {
    isNormalUser = true;
    description = "loss";
    extraGroups = [ "wheel" ]; # Add to 'wheel' group for sudo privileges.
    # Set the default shell for the user. Home Manager will provide detailed Zsh configuration.
    shell = pkgs.zsh;
  };

  # Enable Zsh as a system program.
  # This provides the Zsh executable; Home Manager will layer on top with dotfiles and plugins.
  programs.zsh.enable = true;

  # Add any other general NixOS system configurations here.
  # Example: Enable SSH daemon for remote access (if applicable).
  # services.openssh.enable = true;
}
