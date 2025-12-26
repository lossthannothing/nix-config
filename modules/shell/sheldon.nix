{
  flake.modules = {
    homeManager.shell = {
      pkgs,
      dotfiles,
      ...
    }: {
      home.packages = [pkgs.sheldon];

      home.file.".config/sheldon/plugins.toml".source = "${dotfiles}/config/.config/sheldon/plugins.toml";
    };
  };
}
