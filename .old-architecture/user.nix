# hosts/wsl/user.nix
#
# User configuration for WSL host
# WSL 主机的用户配置
{
  pkgs,
  ...
}:
{
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
  # WSL-specific PATH entries moved to Home Manager (home.sessionPath)
}
