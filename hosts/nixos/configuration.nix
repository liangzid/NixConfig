{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/hyprland.nix
    ../../modules/system/nvidia.nix
    ../../modules/system/fonts.nix
    ../../modules/system/input-method.nix
    ../../modules/system/pipewire.nix
    ../../modules/system/portal.nix
    ../../modules/system/kanata.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Hong_Kong";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_HK.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.logind.settings = {
    Login = {
        HandlePowerKey = "ignore";
        HandleSuspendKey = "ignore";
        HandleHibernateKey = "ignore";
    };
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  services.udisks2.enable = true;

  users.users.zi = {
    isNormalUser = true;
    description = "zi";
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkg.pname or "") [
    "nvidia-x11"
    "nvidia-settings"
    "steam"
    "steam-run"
    "discord"
    "vscode"
    "vscode-fhs"
    "wechat-uos"
    "qq"
    "wemeet"
    "wpsoffice"
    "corefonts"
    "vista-fonts"
    "google-chrome"
    "telegram-desktop"
  ];

  environment.shellAliases = {
    enw = "emacs -nw";
    update = "sudo nixos-rebuild switch --flake ~/code/NixConfig#nixos";
    latexmain = "latexmk --pdflatex main.tex";
    gui = "start-hyprland";
    ec = "emacsclient";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    killall
    tree
    nvtopPackages.full
    btop
    iotop
    eza
    fzf
    duf
    ncdu
    opencode
    firefox
    git
    tmux
    fastfetch
    htop


    wechat-uos
    qq
    wemeet
    wpsoffice
    corefonts
    vista-fonts
    clash-verge-rev
    udiskie
  ];

  programs.nm-applet.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  hardware.steam-hardware.enable = true;
  hardware.graphics.enable = true;

  environment.sessionVariables.TERMINFO_DIRS = "${pkgs.ghostty.terminfo}/share/terminfo";

  system.stateVersion = "26.05";
}
