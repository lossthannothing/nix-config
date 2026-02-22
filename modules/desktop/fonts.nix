# modules/desktop/fonts.nix
#
# Fonts - programming fonts (Nerd Fonts), UI fonts, CJK, emoji
# Registered under homeManager.shell (available to all hosts)
# System-level fontconfig registered under nixos.fonts (desktop hosts only)
{
  flake.modules = {
    # System-level font packages + fontconfig
    nixos.fonts = {pkgs, ...}: {
      fonts = {
        packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-code
          lexend
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          source-han-sans
          source-han-serif
        ];
        fontconfig = {
          defaultFonts = {
            serif = ["Noto Serif CJK SC" "Noto Serif"];
            sansSerif = ["Noto Sans CJK SC" "Noto Sans"];
            monospace = ["JetBrainsMono Nerd Font" "Noto Sans Mono CJK SC"];
            emoji = ["Noto Color Emoji"];
          };
        };
      };
    };

    # HM-level font packages (for standalone HM hosts like fedora-wsl)
    homeManager.shell = {pkgs, ...}: {
      home.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        lexend
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
      ];
    };
  };
}
