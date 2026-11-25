{ config, pkgs, lib, ... }:

let
  wrapTz = import ../../modules/lib/wrap-tz.nix { inherit pkgs lib; };
  hostMemory = import ../../modules/lib/host-memory.nix {
    hostDir = ./.;
  };
in
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
    ../../modules/system/atkbd-resume.nix
    ../../modules/system/zen-browser.nix
    ../../modules/system/throne.nix
    ../../modules/system/codex-desktop.nix
  ];

  hardware.uinput.enable = true;

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
  # wrap-tz sets LANG=en_US.UTF-8 on browsers/AI CLIs; glibc needs the locale.
  i18n.extraLocales = [ "en_US.UTF-8/UTF-8" ];

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
        # 合盖挂起（suspend-to-RAM）：风扇停转、屏幕熄灭、开盖即唤醒恢复。
        # zramSwap 足够，无需磁盘 swap；休眠到磁盘（hibernate）才需要。
        HandleLidSwitch = "suspend";
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

  # 只用 rootless docker（DOCKER_HOST=/run/user/1000/docker.sock）。
  # 不要同时 enable 系统级 dockerd：那会再跑一个 root 守护进程。
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  nix.settings = {
    # 并行度按本机 RAM 算（rebuild 脚本从 /proc/meminfo 写入
    # detected-memory.nix）。Nix 求值读不到 /proc，缺文件则按 16GiB。
    # 本机 ~14GiB → max-jobs=2；读不到则 16GiB 兜底 → 3；cores 均为 4。
    max-jobs = hostMemory.maxJobs;
    cores = hostMemory.cores;
    # 保留 http2=false：疑似 Clash 代理时代的兼容设置；当前下载一切正常，
    # 移除有破坏代理下载的风险，收益不明显。确认代理无碍后可删除。
    http2 = false;
    # 让 nix-shell / nix 命令默认可用 flakes 语法（nixos-rebuild 内部自带）。
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://cache.numtide.com"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://eval-exec.cachix.org"
      "https://nix-wpe-webkit.cachix.org"
      "https://codex-desktop-linux.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "hyprland.cachix.org-1:a7pgxzMz7+chwmg3VQLluhnv4v3C4Y0sYc5LmPzO2v0="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "eval-exec.cachix.org-1:xvopUI7X7+Vt1gaSsWJ0PQFPP66vs8v5iIaz6boxf64="
      "nix-wpe-webkit.cachix.org-1:ItCjHkz1Y5QcwqI9cTGNWHzcox4EqcXqKvOygxpwYHE="
      "codex-desktop-linux.cachix.org-1:nX/xy6AdK9hQE24A8ALGjkCKj2ObFmcnemiL5Cid4nk="
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
    "vivaldi"
    "widevine-cdm"
    "telegram-desktop"
    "grok-bot"
    "claude-code"
    "antigravity-cli"
    "antigravity-hub"
    "devin-desktop"
    "codex-desktop"
  ];

  environment.shellAliases = {
    enw = "emacs -nw";
    # flake 看不见 gitignore 文件：脚本会临时 git add -f，rebuild 后再 unstage。
    update = "$HOME/code/NixConfig/scripts/nixos-rebuild-local.sh switch";
    upgrade = "cd $HOME/code/NixConfig && nix --extra-experimental-features 'nix-command flakes' flake update && $HOME/code/NixConfig/scripts/nixos-rebuild-local.sh switch";
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
    (wrapTz { pkg = llm-agents.claw-code; bins = [ "claw" ]; })
    (wrapTz { pkg = claude-code; bins = [ "claude" ]; })
    # KEYPOINT (review): Google AI Pro/Ultra uses Antigravity, not
    # gemini-cli (personal plans stopped 2026-06-18). llm-agents is
    # newer than nixpkgs (agy 1.5.11 vs 1.5.6; hub is not in nixpkgs).
    (wrapTz { pkg = llm-agents.antigravity-cli; bins = [ "agy" ]; })
    (wrapTz {
      pkg = llm-agents.antigravity-hub;
      bins = [ "antigravity" ];
      extraFlags = [ "--lang=en-US" ];
    })
    llm-agents.code
    (wrapTz { pkg = llm-agents.codex; bins = [ "codex" "codex-code-mode-host" ]; })
    llm-agents.cursor-agent
    llm-agents.dsh
    llm-agents.crush
    llm-agents.omp
    llm-agents.opencode
    llm-agents.reasonix
    llm-agents.hermes-desktop
    llm-agents.agent-browser
    grok-bot
    # KEYPOINT (review): Cognition Windsurf rebrand. nixpkgs fetchurl
    # of the current Windsurf URL; upstream may stop serving old
    # tarballs (nixpkgs#592672). If fetch fails, pin an older
    # info.json or wait for a new hash bump.
    devin-desktop
    pi-coding-agent
    nodejs
    (wrapTz { pkg = firefox; bins = [ "firefox" ]; extraFlags = [ "--lang=en-US" ]; })
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
    udiskie
    system-config-printer

    nautilus
    nautilus-python
    gnome-disk-utility
    caligula
    loupe
    adwaita-icon-theme
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.thunderbird.enable = true;

  programs.nm-applet.enable = true;
  programs.dconf.enable = true;
  # TUN 模式声明式预配：clash-verge GUI 内置的“安装服务”流程要往只读路径
  # 写文件，在 NixOS 上必然失败。改由官方模块开机即起 clash-verge-service
  # （serviceMode，TUN 特权的真正来源，内核由 root 服务拉起），GUI 检测到
  # /run/clash-verge-rev/service.sock 后即可直接打开 TUN 开关；tunMode 负责
  # 把 rp_filter 设为 loose（TUN 下 strict 会丢回程包）并给 GUI 加 capabilities。
  programs.clash-verge = {
    enable = true;
    tunMode = true;
    serviceMode = true;
  };
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

  # zram 压缩页当 swap：不是额外物理内存，挡不住并行编译打满 RAM。
  # 构建侧靠下面 nix-daemon 的 MemoryMax + 按 RAM 降并行度。
  # 如需休眠（suspend-to-disk）再另加 swapfile。
  zramSwap.enable = true;

  # KEYPOINT (review): 百分数由 systemd 按开机物理内存解析，不要写死 GiB。
  # 超限只杀 nix-daemon cgroup 里的构建进程（OOMPolicy=continue），
  # 桌面会话留下。MemoryHigh 先节流，MemoryMax 才硬杀。
  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "50%";
    MemoryMax = "70%";
    OOMPolicy = "continue";
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMSwap = "kill";
  };

  environment.sessionVariables = {
    TERMINFO_DIRS = "${pkgs.ghostty.terminfo}/share/terminfo";
  };


  system.stateVersion = "26.05";
}
