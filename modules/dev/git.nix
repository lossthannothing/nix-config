# modules/dev/git.nix
#
# Git 和 GitHub CLI 配置
topLevel: {
  # 统一接口规范：显式接收 _pkgs
  flake.modules.homeManager.dev = {
    config,
    dotfiles,
    ...
  }: {
    programs.git = {
      enable = true;
      lfs.enable = true;

      # 修复：所有配置项（user, alias, core 等）现在都必须在 settings 下
      settings = {
        # 迁移 userName 和 userEmail
        user = {
          inherit (topLevel.config.flake.meta.users.${config.home.username}) name;
          inherit (topLevel.config.flake.meta.users.${config.home.username}) email;
        };

        # 迁移 extraConfig 中的内容
        init = {
          defaultBranch = "main";
        };
        pull = {
          rebase = true;
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        core = {
          autocrlf = false;
          eol = "lf";
          excludesfile = "~/.global.gitignore";
        };
        column = {
          ui = "auto";
        };
        branch = {
          sort = "-committerdate";
        };
        tag = {
          sort = "version:refname";
        };
        diff = {
          renames = true;
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
        };
        push = {
          followTags = true;
          default = "simple";
          autoSetupRemote = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        merge = {
          conflictstyle = "zdiff3";
        };
        help = {
          autocorrect = "prompt";
        };

        # 迁移 aliases
        alias = {
          br = "branch";
          co = "checkout";
          st = "status";
          ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
          ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
          cm = "commit -m";
          ca = "commit -am";
          dc = "diff --cached";
          amend = "commit --amend -m";
          unstage = "reset HEAD --";
          merged = "branch --merged";
          unmerged = "branch --no-merged";
        };
      };
    };

    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };

    programs.lazygit.enable = true;

    home.file.".global.gitignore".source = "${dotfiles}/git/.global.gitignore";
  };
}
