{ config, pkgs, hermes-agent, ... }:

{
  imports = [
    ../../modules/home/emacs.nix
    ../../modules/home/waybar.nix
    ../../modules/home/gtk.nix
  ];

  home.username = "zi";
  home.homeDirectory = "/home/zi";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    wofi
    waybar
    yazi
    dunst
    libnotify

    juno-theme
    beauty-line-icon-theme

    grim
    slurp
    swappy

    wl-clipboard
    xclip

    awww

    pavucontrol

    wl-clipboard
    w3m
    poppler-utils
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

    gh
    yazi
    

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

    zip
    unzip
    p7zip

    # Media
    imv
    mpv
    termusic
    obs-studio
    vlc

    # pdf
    kdePackages.okular
    zathuraPkgs.zathuraWrapper

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

    shotcut
    kdePackages.kdenlive

    google-chrome

    # Terminal
    ghostty
    wezterm
    zellij

    hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default
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
  home.file."Pictures/Wallpapers" = {
    source = ../../dotfiles/wallpapers;
    recursive = true;
  };

  home.file."scripts/wallpaper-picker.sh" = {
    source = ../../dotfiles/scripts/wallpaper-picker.sh;
    executable = true;
  };

  home.file."${config.xdg.dataHome}/fonts/wps-fonts" = {
    source = ../../dotfiles/fonts/wps;
    recursive = true;
    };

  programs.bash.enable = true;


  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        extraOptions = {
          ServerAliveInterval = "15";
          ServerAliveCountMax = "8";
          TCPKeepAlive = "yes";
          AddKeysToAgent = "yes";
        };
      };
      "is1" = {
        hostname = "is1.astaple.com";
        user = "zi";
      };
      "gs10" = {
        hostname = "gs10.astaple.com";
        user = "zi";
      };
      "gs10o" = {
        hostname = "gs10.astaple.com";
        user = "zi";
        proxyJump = "is1";
      };
      "gs11" = {
        hostname = "gs11.astaple.com";
        user = "zi";
      };
      "gs11o" = {
        hostname = "gs11.astaple.com";
        user = "zi";
        proxyJump = "is1";
      };
      "gs12" = {
        hostname = "gs12.astaple.com";
        user = "zi";
      };
      "gs12o" = {
        hostname = "gs12.astaple.com";
        user = "zi";
        proxyJump = "is1";
      };
      "gs13" = {
        hostname = "gs13.astaple.com";
        user = "zi";
      };
      "gs13o" = {
        hostname = "gs13.astaple.com";
        user = "zi";
        proxyJump = "is1";
      };
      "gs14" = {
        hostname = "gs14.astaple.com";
        user = "zi";
      };
      "gs14o" = {
        hostname = "gs14.astaple.com";
        user = "zi";
        proxyJump = "is1";
      };
      "gs15" = {
        hostname = "gs15.astaple.com";
        user = "zi";
      };
      "gs15o" = {
        hostname = "gs15.astaple.com";
        user = "zi";
        proxyJump = "is1";
      };
      "gs16" = {
        hostname = "gs16.astaple.com";
        user = "zi";
      };
      "gs16o" = {
        hostname = "gs16.astaple.com";
        user = "zi";
        proxyJump = "is1";
      };
      "cs1" = {
        hostname = "cs1.astaple.com";
        user = "zi";
      };
      "cs1o" = {
        hostname = "cs1.astaple.com";
        user = "zi";
        proxyJump = "is1";
      };
      "cs2" = {
        hostname = "cs2.astaple.com";
        user = "zi";
      };
      "cs2o" = {
        hostname = "cs2.astaple.com";
        user = "zi";
        proxyJump = "is1";
      };
      "moreoverai" = {
        hostname = "139.59.220.113";
        user = "ronghua";
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = ["firefox.desktop"];
      "x-scheme-handler/http" = ["firefox.desktop"];
      "x-scheme-handler/https" = ["firefox.desktop"];
      "application/pdf" = ["org.kde.okular.desktop"];
      "image/png" = ["imv.desktop"];
      "image/jpeg" = ["imv.desktop"];
      "image/gif" = ["imv.desktop"];
      "image/webp" = ["imv.desktop"];
      "image/svg+xml" = ["imv.desktop"];
      "video/mp4" = ["mpv.desktop"];
      "video/x-matroska" = ["mpv.desktop"];
      "video/webm" = ["mpv.desktop"];
      "text/plain" = ["emacsclient.desktop"];
      "text/x-python" = ["emacsclient.desktop"];
      "text/x-csrc" = ["emacsclient.desktop"];
      "text/x-shellscript" = ["emacsclient.desktop"];
      "inode/directory" = ["yazi.desktop"];
    };
  };

  xdg.configFile."hypr/hyprland.conf".force = true;
  xdg.configFile."hypr/hyprland.conf".source = ../../dotfiles/hypr/hyprland.conf;
  xdg.configFile."wofi/config".source = ../../dotfiles/wofi/config;
  xdg.configFile."wofi/style.css".source = ../../dotfiles/wofi/style.css;
  xdg.configFile."ghostty/config".source = ../../dotfiles/ghostty/config;
  xdg.configFile."yazi/yazi.toml".source = ../../dotfiles/yazi/yazi.toml;
  xdg.configFile."yazi/keymap.toml".source = ../../dotfiles/yazi/keymap.toml;
  xdg.configFile."clash-verge-rev/merge-hk.yaml".source = ../../dotfiles/clash/merge-hk.yaml;
  xdg.configFile."clash-verge-rev/merge-cn.yaml".source = ../../dotfiles/clash/merge-cn.yaml;
  xdg.configFile."fcitx5/conf/classicui.conf" = {
    source = ../../dotfiles/fcitx5/classicui.conf;
    force = true;
  };
  xdg.configFile."fcitx5/conf/pinyin.conf" = {
    source = ../../dotfiles/fcitx5/pinyin.conf;
    force = true;
  };

  home.activation.cloneEmacs = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/.emacs.d/.git" ]; then
      rm -rf "$HOME/.emacs.d"
      ${pkgs.git}/bin/git clone https://github.com/liangzid/a.emacs.d "$HOME/.emacs.d"
    fi
  '';

}
