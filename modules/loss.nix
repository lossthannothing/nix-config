# modules/loss.nix
#
# User "loss" configuration
# - den.aspects.loss: user-specific NixOS + HM config
# Note: Host binding is defined in modules/hosts/*/default.nix
{__findFile, ...}: {
  den.aspects.loss = {
    includes = [
      <den/primary-user>
      <loss/shell>
      <loss/editors>
    ];

    nixos = {
      users.users.loss = {
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        initialPassword = "password";
      };

      nix.settings.trusted-users = ["loss"];
    };

    homeManager = {
      home = {
        username = "loss";
        homeDirectory = "/home/loss";
        sessionVariables.EDITOR = "nvim";
      };
    };
  };
}
