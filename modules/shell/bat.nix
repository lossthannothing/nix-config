{
  flake.modules.homeManager.shell = {
    programs.bat = {
      enable = true;
      config.theme = "TwoDark";
    };
  };
}
