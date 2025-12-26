# modules/users/loss/default.nix
#
# 用户 loss 的配置
topLevel: {
  flake = {
    # 用户元数据
    meta.users.loss = {
      name = "Loss";
      username = "loss";
      email = "lossilklauralin@gmail.com";
    };

    # NixOS 系统层用户配置
    modules.nixos.loss = _: {
      users.users.loss = {
        description = topLevel.config.flake.meta.users.loss.name;
        isNormalUser = true;
        createHome = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        initialPassword = "password";
      };

      # 添加到 trusted-users
      nix.settings.trusted-users = [topLevel.config.flake.meta.users.loss.username];
    };

    # Home Manager 层用户配置
    modules.homeManager.loss = {
      home = {
        username = "loss";
        homeDirectory = "/home/loss";

        sessionVariables = {
          EDITOR = "nvim";
        };
      };
    };
  };
}
