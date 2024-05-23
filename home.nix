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
    };
    home.packages = with pkgs; [
      neofetch
      htop
      bottom
      exa
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
