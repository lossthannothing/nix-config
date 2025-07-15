# os/nixos.nix

{ config, pkgs, ... }:

{
  # --------------------------------------------------------------------
  # General System Level Configuration
  # --------------------------------------------------------------------

  # Nix Flakes features (typically a global setting, suitable here).
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # System state version; ensure this matches your actual NixOS version.
  system.stateVersion = "24.05"; # Confirm your actual stateVersion.

  # Networking and timezone (define general defaults here; can be overridden in flake.nix for specific configurations).
  networking.hostName = "nixos-generic"; # A generic hostname.
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  # System-level packages.
  # Only place core tools needed by the system administrator or all users here.
  # Avoid packages like neovim, zsh, etc., as Home Manager will install those for your user.
  environment.systemPackages = with pkgs; [
    wget # wget is a general utility, suitable here.
    htop
  ];

  # --------------------------------------------------------------------
  # User and Shell Configuration
  # --------------------------------------------------------------------

  # Create a system user "loss". This must exactly match the username in your home.nix.
  users.users.loss = {
    isNormalUser = true;
    description = "loss";
    extraGroups = [ "wheel" ]; # The `wheel` group grants sudo privileges.
    # Set the default shell. Home Manager will inject detailed configurations for zsh later.
    shell = pkgs.zsh;
  };

  # Basic enablement of Zsh as the system shell; detailed configuration is handled by Home Manager.
  programs.zsh.enable = true;

  # Other general configurations you want on all NixOS systems...
  # For example:
  # services.openssh.enable = true;
  # services.tlp.enable = true; # If it's a laptop.
  # security.sudo.wheelNeedsPassword = false; # Set sudo behavior as needed.
}
