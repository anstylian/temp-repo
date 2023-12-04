{ lib, pkgs, inputs, config, ... }:

{
  imports =
    [
      inputs.sops-nix.nixosModules.sops
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment = {
    systemPackages = with pkgs; [
      # Default packages installed system-wide
      vim
      pciutils
      usbutils
      wget
      tree
      binutils
      file
    ];
  };

  environment.enableAllTerminfo = true;

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = lib.mkDefault "en_US.UTF-8";
    };
    supportedLocales = lib.mkDefault [
      "en_US.UTF-8/UTF-8"
    ];
  };
  time.timeZone = lib.mkDefault "Europe/Athens";

  networking = {
    hostName = "nixos-vm";
  };

  users.mutableUsers = false;
  users.users.user = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "network"
      "git"
    ];
    shell = pkgs.bash;
    initialPassword = "testpw";
  };

  users.users.root.initialPassword = "testpw";

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  # generate new key at ~/.config/sops/age/keys.txt --> age-keygen -o ~/.config/sops/age/keys.txt
  # public key of ~/.config/sops/age/keys.txt --> age-keygen -y ~/.config/sops/age/keys.txt
  sops.age.keyFile = "/home/angelos/.config/sops/age/keys.txt";

  sops.secrets.example-key = { };
  sops.secrets."myservice/my_subdir/my_secret" = {
    # owner = "sometestservice";
  };

  # systemd.services."sometestservice" = {
  #   script = ''
  #       echo "
  #       Hey bro! I'm a service, and imma send this secure password:
  #       $(cat ${config.sops.secrets."myservice/my_subdir/my_secret".path})
  #       located in:
  #       ${config.sops.secrets."myservice/my_subdir/my_secret".path}
  #       to database and hack the mainframe
  #       " > /var/lib/sometestservice/testfile
  #     '';
  #   serviceConfig = {
  #     User = "sometestservice";
  #     WorkingDirectory = "/var/lib/sometestservice";
  #   };
  # };
  #
  # users.users.sometestservice = {
  #   home = "/var/lib/sometestservice";
  #   createHome = true;
  #   isSystemUser = true;
  #   group = "sometestservice";
  # };
  # users.groups.sometestservice = { };

  system.stateVersion = "24.05";
}
