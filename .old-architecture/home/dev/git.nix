# home/git.nix
#
# Git configuration module
# Git 配置模块
#
# This module contains all Git-related configurations including
# the main git program configuration and related dotfiles.
{dotfiles, ...}: {
  # GitHub CLI tool
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

  programs.git = {
    enable = true;
    userName = "Lossilklauralin";
    userEmail = "lossilklauralin@gmail.com";
    lfs.enable = true;

    extraConfig = {
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
    };

    aliases = {
      # common aliases
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

  # Git terminal UIs
  programs.lazygit.enable = true;

  # Git-related dotfiles
  home.file = {
    ".global.gitignore".source = "${dotfiles}/git/.global.gitignore";
  };
}
