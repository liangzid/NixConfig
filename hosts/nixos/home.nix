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
    grimblast
    satty

    wl-clipboard
    xclip

    awww

    pavucontrol
    gnome-calendar

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
    # 注意：GTK_IM_MODULE 不在这里设置。waylandFrontend=true 后 NixOS
    # 不再全局设置它：Wayland 原生 GTK 走 text-input-v3，X11/XWayland
    # GTK 由 gtk-3.0/gtk-4.0 settings.ini 指定 fcitx 模块。
    # Qt 在非 KDE 合成器下必须显式指定 fcitx（WPS 等依赖）。
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
    INPUT_METHOD = "fcitx";

    # pi-coding-agent (Nix-managed, disable self-update checks)
    PI_OFFLINE = "1";

    # NVIDIA / Wayland 会话变量在 hyprland.lua 的 hl.env 里设置，
    # 不要放进 sessionVariables：TTY 与 SSH 也会继承。
  };

  # 壁纸只轮换仓库里的图：dotfiles/wallpapers + images/（排除 screenshot_*）。
  # 新壁纸放进仓库对应目录，不要往 ~/Pictures 里丢散文件。
  home.file."Pictures/Wallpapers" = {
    source = ../../dotfiles/wallpapers;
    recursive = true;
    force = true;
  };

  home.file."Pictures/Images" = {
    source = ../../images;
    recursive = true;
    force = true;
  };

  home.file."scripts/wallpaper-picker.sh" = {
    source = ../../dotfiles/scripts/wallpaper-picker.sh;
    executable = true;
    force = true;
  };

  home.file."scripts/screenshot.sh" = {
    source = ../../dotfiles/scripts/screenshot.sh;
    executable = true;
    force = true;
  };

  home.file."${config.xdg.dataHome}/fonts/wps-fonts" = {
    source = ../../dotfiles/fonts/wps;
    recursive = true;
    };

  programs.bash.enable = true;
  # 本机密钥：~/.bashrc.local（不进 git）。改完新开 shell 即可，不必 rebuild。
  programs.bash.initExtra = ''
    if [ -f "$HOME/.bashrc.local" ]; then
      . "$HOME/.bashrc.local"
    fi
  '';

  # OpenSSH 要求 ~/.ssh/config 属主为 root 或当前用户，而 HM 生成的
  # store 文件属主是 nobody，会被 ssh 拒绝（Bad owner or permissions）。
  # 激活后把 config 复制成真实文件（600），保持声明式内容不变。
  home.activation.sshConfigRealFile = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -L "$HOME/.ssh/config" ]; then
      storeConfig="$(readlink "$HOME/.ssh/config")"
      $DRY_RUN_CMD rm "$HOME/.ssh/config"
      $DRY_RUN_CMD cp "$storeConfig" "$HOME/.ssh/config"
      $DRY_RUN_CMD chmod 600 "$HOME/.ssh/config"
    fi
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

  # Hyprland >= 0.55 改用 Lua 配置（hyprland.lua），旧 hyprlang 的
  # hyprland.conf 已不再被读取。
  xdg.configFile."hypr/hyprland.lua".force = true;
  xdg.configFile."hypr/hyprland.lua".source = ../../dotfiles/hypr/hyprland.lua;
  xdg.configFile."wofi/config".force = true;
  xdg.configFile."wofi/config".source = ../../dotfiles/wofi/config;
  xdg.configFile."wofi/style.css".force = true;
  xdg.configFile."wofi/style.css".source = ../../dotfiles/wofi/style.css;
  xdg.configFile."ghostty/config".source = ../../dotfiles/ghostty/config;
  xdg.configFile."dunst/dunstrc".force = true;
  xdg.configFile."dunst/dunstrc".source = ../../dotfiles/dunst/dunstrc;
  xdg.configFile."clash-verge-rev/merge-hk.yaml".source = ../../dotfiles/clash/merge-hk.yaml;
  xdg.configFile."clash-verge-rev/merge-cn.yaml".source = ../../dotfiles/clash/merge-cn.yaml;
  home.activation.cloneEmacs = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/.emacs.d/.git" ]; then
      rm -rf "$HOME/.emacs.d"
      ${pkgs.git}/bin/git clone https://github.com/liangzid/a.emacs.d "$HOME/.emacs.d"
    fi
  '';

}
