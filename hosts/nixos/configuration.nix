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
  # 限制引导菜单保留的世代数，防止 300M 的 ESP 被旧内核/initrd 塞满
  # （systemd-boot 每个世代约 56M：kernel 14M + initrd 42M）。
  boot.loader.systemd-boot.configurationLimit = 4;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];

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
  services.gvfs.enable = true;

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint
    hplip
    brlaser
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  users.users.zi = {
    isNormalUser = true;
    description = "zi";
    # 已启用 rootless docker（默认 context 指向 /run/user/1000/docker.sock），
    # 不再需要 docker 组（该组等价于 root，会绕过 rootless 隔离）。
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
    packages = with pkgs; [];
  };

  # Docker service
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  nix.settings = {
    # i5-13400F（16 线程），放开并行度加速构建；cores=0 表示不限制。
    max-jobs = 8;
    cores = 0;
    # 保留 http2=false：疑似 Clash 代理时代的兼容设置；当前下载一切正常，
    # 移除有破坏代理下载的风险，收益不明显。确认代理无碍后可删除。
    http2 = false;
    # 让 nix-shell / nix 命令默认可用 flakes 语法（nixos-rebuild 内部自带）。
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://cache.numtide.com"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.thalheim.io"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "hyprland.cachix.org-1:a7pgxzMz7+chwmg3VQLluhnv4v3C4Y0sYc5LmPzO2v0="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
    ];
  };

  # 自动回收 /nix/store 中 7 天前的旧世代，避免无限膨胀。
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
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
    upgrade = "cd ~/code/NixConfig && nix --extra-experimental-features 'nix-command flakes' flake update && sudo nixos-rebuild switch --flake ~/code/NixConfig#nixos";
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
    llm-agents.claw-code
    llm-agents.code
    llm-agents.codex
    llm-agents.cursor-agent
    llm-agents.crush
    llm-agents.omp
    llm-agents.opencode
    llm-agents.reasonix
    llm-agents.hermes-desktop
    llm-agents.agent-browser
    pi-coding-agent
    nodejs
    firefox
    git
    tmux
    fastfetch
    htop
    postgresql_17
    docker-compose
    openssl
    # WiFi AP / sniffing tools
    iw
    hostapd
    dnsmasq
    tcpdump
    tshark


    wechat-uos
    qq
    wemeet
    wpsoffice
    corefonts
    vista-fonts
    clash-verge-rev
    udiskie
    system-config-printer

    nautilus
    nautilus-python
    gnome-disk-utility
    loupe
    adwaita-icon-theme
  ];

  programs.nm-applet.enable = true;
  programs.dconf.enable = true;
  # 禁用 systemd-ssh-proxy 的系统 Include：NixOS 生成的 /etc/ssh/ssh_config
  # 会 Include systemd 包里的 store 文件（属主 nobody），OpenSSH 10.4 的
  # 属主检查直接拒绝（Bad owner or permissions），导致所有 ssh 命令失败。
  programs.ssh.systemd-ssh-proxy.enable = false;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  hardware.steam-hardware.enable = true;
  hardware.graphics.enable = true;

  # 31G 内存 + 无磁盘 swap：zram 压缩内存作为 swap，防止内存压力下 OOM。
  # 如需休眠（suspend-to-disk）再另加 swapfile。
  zramSwap.enable = true;

  environment.sessionVariables = {
    GDK_BACKEND = "wayland";
    TERMINFO_DIRS = "${pkgs.ghostty.terminfo}/share/terminfo";
  };

  system.stateVersion = "26.05";
}
