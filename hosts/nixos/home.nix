{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/emacs.nix
    ../../modules/home/waybar.nix
    ../../modules/home/gtk.nix
    ../../modules/home/common-lisp.nix
  ];

  home.username = "zi";
  home.homeDirectory = "/home/zi";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    wofi
    waybar
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

    uv

    gh

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
    gnumake

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
    mupdf

    # Develop (Just for back up)
    vscode-fhs
    texliveFull

    # Other IM channel
    discord
    telegram-desktop
    zapzap

    # Gaming
    steam-run

    drawio
    libreoffice
    xournalpp

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
  ];

  home.shellAliases = {
    xclip = "wl-copy";
  };

  home.sessionVariables = {
    # GTK_IM_MODULE intentionally unset on Wayland — fcitx5's Wayland input
    # method frontend (via fcitx5-gtk / xdg-desktop-portal) handles GTK apps.
    # Setting it to "fcitx" forces the legacy XIM path and triggers fcitx5's
    # diagnostic warning. See https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
    INPUT_METHOD = "fcitx";

    # pi-coding-agent (Nix-managed, disable self-update checks)
    PI_OFFLINE = "1";

    # For Nvidia
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # ---- sops-nix：密钥管理（替代已废弃的 hosts/nixos/env-private.json）----
  # 密钥文件 secrets/secrets.yaml 用 age 加密（.sops.yaml 定义接收者），
  # 解密用的 age 密钥由 ~/.ssh/id_ed25519 在激活时自动转换而来。
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/home/zi/.ssh/id_ed25519" ];
    secrets.DEEPSEEK_API_KEY.path =
      "/home/zi/.config/sops-nix/secrets/DEEPSEEK_API_KEY";
  };

  # 把密钥导出到全局用户会话：
  # - systemd user 服务（含之后启动的 user units）由 set-environment 提供；
  # - D-Bus 激活的程序由 dbus-update-activation-environment 提供；
  # - Hyprland 直接 exec 的程序从登录 shell 继承（下方 bash initExtra）。
  # 密钥变更后需要重启该服务或重新登录才会刷新。
  systemd.user.services.sops-secrets-env = {
    Unit = {
      Description = "Export sops-nix secrets into the user session";
      After = [ "sops-nix.service" ];
      Requires = [ "sops-nix.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = toString (pkgs.writeShellScript "sops-secrets-env" ''
        keyfile="${config.sops.secrets.DEEPSEEK_API_KEY.path}"
        if [[ -r "$keyfile" ]]; then
          export DEEPSEEK_API_KEY="$(cat "$keyfile")"
          ${pkgs.systemd}/bin/systemctl --user set-environment DEEPSEEK_API_KEY="$DEEPSEEK_API_KEY"
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DEEPSEEK_API_KEY || true
        fi
      '');
    };
    Install.WantedBy = [ "default.target" ];
  };

  home.file."Pictures/Wallpapers" = {
    source = ../../dotfiles/wallpapers;
    recursive = true;
    force = true;
  };

  home.file."scripts/wallpaper-picker.sh" = {
    source = ../../dotfiles/scripts/wallpaper-picker.sh;
    executable = true;
    force = true;
  };

  home.file."${config.xdg.dataHome}/fonts/wps-fonts" = {
    source = ../../dotfiles/fonts/wps;
    recursive = true;
    };

  programs.bash.enable = true;
  # home.sessionVariables 不支持命令替换，密钥在激活时解密为普通文件，
  # 所以在 bash 启动时读文件导出。
  programs.bash.initExtra = ''
    export DEEPSEEK_API_KEY="$(cat ${config.sops.secrets.DEEPSEEK_API_KEY.path})"
  '';


  programs.ssh = {
    enable = true;
    # 保持开启：HM 统一生成 ~/.ssh/config（settings 是唯一来源）。
    # 旧的手动文件由 flake.nix 里的 home-manager.backupFileExtension
    # 在下次激活时自动备份为 config.backup，不会中断激活。
    # matchBlocks 已弃用，改用等价的 settings（OpenSSH 原生指令名）。
    enableDefaultConfig = false;
    settings = {
      # 显式保留旧 enableDefaultConfig 的默认值，避免未来默认值移除后行为变化。
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "yes";
        Compression = false;
        ServerAliveInterval = 15;
        ServerAliveCountMax = 8;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
        TCPKeepAlive = "yes";
        StrictModes = "no";
      };
      is1 = {
        HostName = "is1.astaple.com";
        User = "zi";
      };
      gs10 = {
        HostName = "gs10.astaple.com";
        User = "zi";
      };
      gs10o = {
        HostName = "gs10.astaple.com";
        User = "zi";
        ProxyJump = "is1";
      };
      gs11 = {
        HostName = "gs11.astaple.com";
        User = "zi";
      };
      gs11o = {
        HostName = "gs11.astaple.com";
        User = "zi";
        ProxyJump = "is1";
      };
      gs12 = {
        HostName = "gs12.astaple.com";
        User = "zi";
      };
      gs12o = {
        HostName = "gs12.astaple.com";
        User = "zi";
        ProxyJump = "is1";
      };
      gs13 = {
        HostName = "gs13.astaple.com";
        User = "zi";
      };
      gs13o = {
        HostName = "gs13.astaple.com";
        User = "zi";
        ProxyJump = "is1";
      };
      gs14 = {
        HostName = "gs14.astaple.com";
        User = "zi";
      };
      gs14o = {
        HostName = "gs14.astaple.com";
        User = "zi";
        ProxyJump = "is1";
      };
      gs15 = {
        HostName = "gs15.astaple.com";
        User = "zi";
      };
      gs15o = {
        HostName = "gs15.astaple.com";
        User = "zi";
        ProxyJump = "is1";
      };
      gs16 = {
        HostName = "gs16.astaple.com";
        User = "zi";
      };
      gs16o = {
        HostName = "gs16.astaple.com";
        User = "zi";
        ProxyJump = "is1";
      };
      cs1 = {
        HostName = "cs1.astaple.com";
        User = "zi";
      };
      cs1o = {
        HostName = "cs1.astaple.com";
        User = "zi";
        ProxyJump = "is1";
      };
      cs2 = {
        HostName = "cs2.astaple.com";
        User = "zi";
      };
      cs2o = {
        HostName = "cs2.astaple.com";
        User = "zi";
        ProxyJump = "is1";
      };
      moreoverai = {
        HostName = "139.59.220.113";
        User = "ronghua";
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
      "inode/directory" = ["org.gnome.Nautilus.desktop"];
    };
  };

  xdg.configFile."hypr/hyprland.conf".force = true;
  xdg.configFile."hypr/hyprland.conf".source = ../../dotfiles/hypr/hyprland.conf;
  xdg.configFile."wofi/config".force = true;
  xdg.configFile."wofi/config".source = ../../dotfiles/wofi/config;
  xdg.configFile."wofi/style.css".force = true;
  xdg.configFile."wofi/style.css".source = ../../dotfiles/wofi/style.css;
  xdg.configFile."ghostty/config".source = ../../dotfiles/ghostty/config;
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
