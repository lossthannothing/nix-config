# os/wsl.nix

{ config, pkgs, ... }: # Ensure 'pkgs' is available in this module's scope

{
  # --------------------------------------------------------------------
  # WSL-Specific System Configuration
  # --------------------------------------------------------------------

  # Enable the core WSL integration provided by NixOS-WSL.
  # wsl.enable = true;
  # Set the default user for the WSL instance. This is crucial for initial login.
  # It should match the user defined in ./os/nixos.nix.
  wsl.defaultUser = "loss"; # Ensure this matches the 'loss' user you're setting up.
  # Override the general hostname for this specific WSL instance.
  networking.hostName = "nixos-wsl";

  # Disable bootloaders, as WSL handles booting differently and they are not needed.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = false;

  # --- Solution for VS Code Remote SSH on WSL: Using nix-ld ---
  # This enables nix-ld to provide compatibility for dynamically linked
  # foreign binaries (like the Node.js binary used by VS Code Remote Server).
  programs.nix-ld.enable = true;

  # You can add other WSL-specific configurations here if needed.
  # For example, if you have specific networking requirements for WSL that differ
  # from a general Linux setup.
}
