# modules/dev.nix
#
# loss.dev - Development tools
# Merged from: dev/git.nix, dev/editors.nix, dev/direnv.nix, dev/just.nix,
#   dev/hyperfine.nix, dev/ripgrep.nix, dev/ansible.nix, dev/devenv.nix
{
  loss.dev.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      neovim
      ansible
      devenv
      hyperfine
      just
    ];

    # Git
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "Loss";
          email = "lossilklauralin@gmail.com";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        core = {
          autocrlf = false;
          eol = "lf";
          excludesfile = "~/.global.gitignore";
        };
        column.ui = "auto";
        branch.sort = "-committerdate";
        tag.sort = "version:refname";
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
        merge.conflictstyle = "zdiff3";
        help.autocorrect = "prompt";
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

    home.file.".global.gitignore".text = ''
      .DS_Store
      .env
      *.local.*
    '';

    # Direnv
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Ripgrep
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };
  };
}
