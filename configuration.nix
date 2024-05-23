{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "nix";

  timeZone = "Europe/Moscow";
  defaultLocale = "en_US.UTF-8";

  hardware-config = "/home/${user}/dotfiles/nixos/devices/raspberrypi.nix";
  home-config = "/home/${user}/dotfiles/nixos/home.nix";
  sops-nix = "${fetchTarball "https://github.com/Mic92/sops-nix/archive/master.tar.gz"}/modules/sops";
in {
  imports = [
    hardware-config
    sops-nix
    home-config
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
      sops
    ];
    variables = {
      GPG_TTY = "$tty";
    };
  };

  programs = {
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

  sops = {
    # Add secrets.yaml to the nix store
    # This can be avoided by adding a string to the full path instead, i.e.
    # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age = {
      # Use an age key that is expected to already be in the filesystem
      keyFile = "/var/lib/sops-nix/key.txt";
    };
    secrets = {
      # echo "password" | mkpasswd -s
      nix-password = {};
      # https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password
      nix-password.neededForUsers = true;
      # Public SSH keys
      ssh-wsl-pub = {};
      ssh-winster-pub = {};
      github-token = {};
      git-signing-key-personal = {};
      git-email-personal = {};
      git-username-personal = {};
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
      hashedPasswordFile = config.sops.secrets.nix-password.path;
      openssh.authorizedKeys.keys = [
        config.sops.secrets.ssh-wsl-pub.path
        config.sops.secrets.ssh-winster-pub.path
      ];
      extraGroups = ["wheel" "video"];
    };
  };

  # Enable regular nix store garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "24.05";
}
