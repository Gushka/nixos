{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "nix";
  password = "nix";

  timeZone = "Europe/Moscow";
  defaultLocale = "en_US.UTF-8";

  hardware-config = "/home/${user}/dotfiles/nixos/devices/raspberrypi.nix";
in {
  imports = [
    hardware-config
  ];

  time.timeZone = timeZone;

  i18n = {
    defaultLocale = defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = defaultLocale;
      LC_IDENTIFICATION = defaultLocale;
      LC_MEASUREMENT = defaultLocale;
      LC_MONETARY = defaultLocale;
      LC_NAME = defaultLocale;
      LC_NUMERIC = defaultLocale;
      LC_PAPER = defaultLocale;
      LC_TELEPHONE = defaultLocale;
      LC_TIME = defaultLocale;
    };
  };

  environment = { 
    systemPackages = with pkgs; [
      vim
      alejandra
      gnupg
      pinentry-curses
    ];
    variables = {
      GPG_TTY = "$tty";
    };
  }; 

  programs = {
    git = {
      enable = true;
      config = {
        init.defaultbranch = "master";
        commit.gpgsign = true;
        tag.gpgsign = true;
        diff.tool = "vimdiff";
        merge.tool = "vimdiff";
      };
    };
    gnupg.agent = {
      enable = true;
      settings = {
        default-cache-ttl = 86400;
        max-cache-ttl = 86400;
      };
    };
  };

  # Enable openSSH daemon and permit only key-based auth
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Permit password-less sudo
  security.sudo.extraRules = [
    {
      users = [user];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      password = password;
      extraGroups = ["wheel" "video"];
      packages = with pkgs; [
        neofetch
        htop
      ];
    };
  };

  system.stateVersion = "24.05";
}
