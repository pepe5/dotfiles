{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./modules/media.nix
    ./modules/android.nix
    ./modules/emacs.nix
    ./modules/malicious-hosts.nix
    ./my-hosts.nix
  ];

  boot.tmpOnTmpfs = true;

  boot.bindEtcNixos = {
    enable = true;
    location = "/home/m/.dotfiles/.nixos-config.symlink";
  };

  powerManagement = {
    powerDownCommands = ''
      ${pkgs.procps}/bin/pgrep ssh | while IFS= read -r pid ; do
        [ "$(readlink "/proc/$pid/exe")" = "${pkgs.openssh}/bin/ssh" ] && kill "$pid"
      done
    '';
    powerUpCommands = ''
      ${pkgs.eject}/bin/eject -i on /dev/sr0 # Why isn’t this working‽ How to block the CD eject button?
    '';
  };

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    bitcoin
    cabal2nix
    cdrkit
    chromium
    compton
    cool-retro-term
    dunst
    evince
    gettext
    gettext-emacs
    ghostscript
    gnome2.gnome_icon_theme
    gnome3.dconf   # so that GnuCash prefs can be changed
    gnome3.adwaita-icon-theme
    gnome3.gnome_themes_standard
    gnucash26
    gparted
    (haskellPackages.ghcWithHoogle (hs: []))
    haskellPackages.hlint
    haskellPackages.intero-nix-shim
    isync
    lemonbar-xft
    libreoffice
    mu
    networkmanagerapplet
    oathToolkit
    octave
    openjdk8
    pass
    pavucontrol
    pcmanfm
    pinentry
    rofi
    scala
    shellcheck
    stack
    stalonetray
    (texlive.combine {
      inherit (texlive) scheme-small latexmk titlesec tocloft todonotes cleveref lipsum biblatex logreq cm-super csquotes pgfplots adjustbox collectbox ccicons polski placeins xstring pdfpages unicode-math filehook textpos marvosym progressbar lm-math;
      gregorio = pkgs.gregorio.forTexlive;
    })
    sxhkd
    transmission_gtk
    utox
    visualvm
    xarchiver
    xsane
  ];

  environment.variables."GTK2_RC_FILES" =
    "${pkgs.gnome3.gnome_themes_standard}/share/themes/Adwaita/gtk-2.0/gtkrc";

  programs = {
    ssh.startAgent = false;
    wireshark.enable = true;
    wireshark.package = pkgs.wireshark-gtk;
  };

  virtualisation.virtualbox.host.enable = true;

  hardware.android.automount = let user = config.users.users.m; in {
    enable = true;
    user = user.name;
    point = "${user.home}/Phone";
  };

  services = {
    logind.extraConfig = ''
      HandleLidSwitch=suspend
      HandlePowerKey=suspend
    '';

    lockX11Displays.enable = true;

    screen.usersAlways = [];

    xserver = {
      xkbOptions = "caps:hyper,numpad:microsoft";

      synaptics = {
        maxSpeed = "4.0";
        accelFactor = "0.02";
        additionalOptions = ''
          Option "VertScrollDelta" "-114"
          Option "HorizScrollDelta" "-114"
        '';
      };

      displayManager.lightdm.enable = true;
      desktopManager.xterm.enable = false;
      windowManager.bspwm.enable = true;

      displayManager.xserverArgs = [ "-ardelay" "150" "-arinterval" "8" ];
    };
  };

  fonts.fonts = with pkgs; [
    anonymousPro
    hack-font
    iosevka
    font-awesome-ttf
  ];

  users = {
    guestAccount = {
      enable = true;
      skeleton = "/home/guest.skel";
      groups = [ "audio" "nonet" "scanner" "networkmanager" "vboxusers" ];
    };

    extraUsers.m = {
      hashedPassword = "$6$wO42jkhqerm$kl.qIl5USrzqAZOIkXdicrBLBgVwka2Dz81nc.aNsNJZREXY.02XxPdL1FiTCcuVP2K/DSmXqAQ3aPbri/v.g1";
      isNormalUser = true;
      uid = 31337;
      description = "Michal Rus";
      extraGroups = [ "wheel" "audio" "nonet" "scanner" "networkmanager" "vboxusers" "wireshark" "cdrom" ];
    };

    extraUsers.mw = {
      hashedPassword = "$6$EDtlcw2d9XVBOw$Y0SLSpFnAc/tc3z8/Y4cQK/p.Vuqkwz0HHBkYcDAlUI3lHOFJQBj0cscE30qs2YoxsoUwOxIno0g4zhZUsZ7R1";
      isNormalUser = true;
      uid = 1337;
      description = "Michal Rus (work)";
      extraGroups = [ "nonet" "scanner" "networkmanager" "vboxusers" "wireshark" "cdrom" ];
    };
  };

  fileSystems."/var/home/mw/.shared" = {
    device = "/var/home/m/.shared";
    fsType = "fuse.bindfs";
    options = [ "map=m/mw" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
