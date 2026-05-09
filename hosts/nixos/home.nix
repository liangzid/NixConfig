{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/emacs.nix
    ../../modules/home/waybar.nix
    ../../modules/home/foot.nix
    ../../modules/home/gtk.nix
  ];

  home.username = "zi";
  home.homeDirectory = "/home/zi";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    wofi
    waybar
    foot
    nemo
    dunst
    libnotify

    juno-theme
    beauty-line-icon-theme

    grim
    slurp

    wl-clipboard
    xclip

    awww

    pavucontrol

    wl-clipboard
    w3m
    aspell
    scrot
    jdk17
    graphviz
    python3
    mplayer
    socat
    cmake
    ripgrep
    silver-searcher
    uv

    pkg-config
    glib
    openssl
    gtk3
    atk
    librime
    libtool
    mesa
    freeglut
    enchant
    gcc


    # Media
    imv
    mpv
    termusic
    obs-studio
    vlc

    # Develop (Just for back up)
    vscode-fhs
    texliveFull

    # Other IM channel
    discord
    telegram-desktop
    zapzap

    # Gaming
    steam-run


    # Locking Screen and Laptop-Related
    swaylock-effects
    swayidle

  ];

  home.shellAliases = {
    xclip = "wl-copy";
  };

  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
    INPUT_METHOD = "fcitx";

    # For Nvidia
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  programs.bash.enable = true;


  xdg.mimeApps.enable = true;

  xdg.configFile."hypr/hyprland.conf".force = true;
  xdg.configFile."hypr/hyprland.conf".source = ../../dotfiles/hypr/hyprland.conf;
  xdg.configFile."wofi/config".source = ../../dotfiles/wofi/config;
  xdg.configFile."wofi/style.css".source = ../../dotfiles/wofi/style.css;
}
