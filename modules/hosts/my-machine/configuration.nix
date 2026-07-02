{ self, inputs, ... }: {
  flake.nixosModules.myMachineConfiguration = { config, pkgs, lib, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      self.nixosModules.myMachineHardware
      self.nixosModules.niri
      self.nixosModules.home 
      self.nixosModules.noctalia
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "myMachine"; # Define your hostname.
    networkmanager.enable = true;
  };

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024;  # 16GB - adjust based on your RAM size
  }];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Console keymap (Wayland keyboard layout is set in Niri's input config)
  console.keyMap = "it2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.redue = {
    isNormalUser = true;
    description = "Redue";
    extraGroups = [ "networkmanager" "wheel" "video"];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "niri-session";
        user = "redue";
      };
      default_session = {
        command = "niri-session";
        user = "redue";
      };
    };
  };


  services.flatpak.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/redue/NIX";
  };


  nix.settings.auto-optimise-store = true;
  nix.settings.max-jobs = "auto";

  boot.loader.systemd-boot.configurationLimit = 3;
  # Install firefox.
  programs.firefox.enable = true;

  programs.kdeconnect.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "replace"
  ];
  nixpkgs.config.permittedInsecurePackages = [
   "openssl-1.1.1w"
  ];
  nixpkgs.config.problems.handlers = {
      sublimetext4.broken = "ignore";
   };
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Binary caches — nix-community covers many packages not in the official cache
    substituters = [
      "https://cache.nixos.org"
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBc="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
    # Cache flake evaluation results to speed up subsequent rebuilds
    eval-cache = true;
    # Don't cache failed cache lookups — always retry substituters
    narinfo-cache-negative-ttl = 0;
  };

  environment.systemPackages = with pkgs; [
    git
    brightnessctl    # brightness keys
    lxqt.lxqt-policykit  # polkit agent
    wl-clipboard     # wayland clipboard
    cliphist         # clipboard history
    xdg-utils        # makes "open with" work properly
    libnotify        # desktop notifications
    wireplumber      # audio control (wpctl)
    mpv              # general-purpose media player
    satty            # screenshot annotation tool
    nix-tree         # interactively browse nix store dependencies
    nomacs           # image viewer
    kdePackages.okular  # document viewer
    yazi             # file manager 
    ncdu             # disk usage analyzer
    baobab           # disk usage visualizer
    gdk-pixbuf          # standard image thumbnails (PNG, JPEG, etc.)
    ffmpegthumbnailer   # video thumbnails
    ffmpeg-headless     # needed by ffmpegthumbnailer
    libgsf              # ODF/document thumbnails
    ripgrep
    fd              # improved find
    libheif
    curl
    unzip             # zip support
    _7zz              # 7z support
    file-roller
    mission-center
    warehouse         # manage flatpaks
  ];


  xdg.portal = {
  enable = true;
  extraPortals = [
      pkgs.xdg-desktop-portal-gtk  # handles file picker with any GTK file manager
      pkgs.xdg-desktop-portal-gnome
    ];
    config.common.default = "gtk";
    config.common."org.freedesktop.impl.portal.ScreenCast" = "gnome";
    config.common."org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
 };


 programs.thunar = {
  enable = true;
  plugins = with pkgs.xfce; [
    thunar-archive-plugin  # right-click "Extract Here" / "Compress"
  ];
};

xdg.portal.config.common."org.freedesktop.impl.portal.FileChooser" = "gtk";

 programs.nix-ld.enable = true;
 services.gvfs.enable = true;
 services.tumbler.enable = true;
 services.udisks2.enable = true;
 services.upower.enable = true;
 xdg.mime.enable = true;
 xdg.menus.enable = true;
 services.power-profiles-daemon.enable = true;
 programs.steam.enable = true;
 virtualisation.podman.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

};

}
