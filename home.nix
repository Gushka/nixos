{
  config,
  pkgs,
  lib,
  ...
}: let
  home-manager = "${fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz"}/nixos";
  user = "nix";
in {
  imports = [
    home-manager
  ];

  # TODO: declare username var globally
  home-manager.users."${user}" = {
    programs = {
      bash = {
        enable = true;
      };
      git = {
        enable = true;
        signing = {
          signByDefault = true;
          key = config.sops.secrets.git-signing-key-personal.path;
        };
        # Sorry robots :/
        userEmail = config.sops.secrets.git-email-personal.path;
        userName = config.sops.secrets.git-username-personal.path;
        extraConfig = {
          init.defaultBranch = "master";
          diff.tool = "vimdiff";
          merge.tool = "vimdiff";
          # https://github.com/getsops/sops#showing-diffs-in-cleartext-in-git
          # Workaround for: https://github.com/getsops/sops/issues/884#issuecomment-1399395740
          diff.sopsdiffer.textconv = "sops --config /dev/null -d";
        };
      };
    };
    home.packages = with pkgs; [
      neofetch
      htop
      bottom
      eza
      ripgrep
      tldr
      difftastic
    ];
    home.stateVersion = "24.05";
  };

  # Install home-manager pkgs in /etc/profiles
  home-manager.useUserPackages = true;
  # Disable default home-manager of using a private nixpkgs instance
  home-manager.useGlobalPkgs = true;
}
