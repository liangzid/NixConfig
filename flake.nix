{
  # Root is a trusted user, so nixos-rebuild (sudo) honors this on the
  # first switch — before configuration.nix has rewritten nix.conf.
  nixConfig = {
    extra-substituters = [
      "https://eval-exec.cachix.org"
      "https://nix-wpe-webkit.cachix.org"
      "https://codex-desktop-linux.cachix.org"
    ];
    extra-trusted-public-keys = [
      "eval-exec.cachix.org-1:xvopUI7X7+Vt1gaSsWJ0PQFPP66vs8v5iIaz6boxf64="
      "nix-wpe-webkit.cachix.org-1:ItCjHkz1Y5QcwqI9cTGNWHzcox4EqcXqKvOygxpwYHE="
      "codex-desktop-linux.cachix.org-1:nX/xy6AdK9hQE24A8ALGjkCKj2ObFmcnemiL5Cid4nk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
    grok-bot = {
      url = "github:jordangarrison/grok-bot-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # neomacs is parked: we are not using it yet. Re-enable the input,
    # outputs arg, overlay splice, and home.nix import together.
    # Do not nixpkgs.follows: crane / rust-overlay / nix-wpe-webkit are
    # pinned to neomacs' own nixpkgs. Following ours forces a WPE rebuild.
    # neomacs.url = "github:eval-exec/neomacs";
    # Do not nixpkgs.follows: nix-openclaw pins pnpm/qmd/tool packages.
    # Following ours would rebuild their toolchain against our nixpkgs.
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    # Do not nixpkgs.follows: upstream cachix is built against their
    # own nixos-unstable pin. Following ours would rebuild the .deb
    # wrap instead of substituting.
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, llm-agents, grok-bot, zen-browser, nix-openclaw, codex-desktop-linux, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # youwen5 1.24.2b sources.json already matches the GitHub tarball.
    # The 1.23.3b hash-override overlay is no longer needed.
    zenBrowserOverlay = final: prev: {
      zen-browser = zen-browser.packages.${system}.zen-browser;
    };

    # KEYPOINT (review): llm-agents hermes-desktop 0.23.0 runs
    # `tsc --noEmit` then in-process vite. The Nix sandbox hides RAM, so
    # Node keeps the ~2 GiB default heap and tsc SIGABRTs
    # ("JavaScript heap out of memory"). 6144 is the smallest size known
    # to finish tsc+vite (NousResearch/hermes-agent#125502). Do not use
    # upstream's 16384: MemoryMax=70% of this ~15 GiB laptop is ~10 GiB.
    hermesDesktopHeapOverlay = final: prev: {
      llm-agents = prev.llm-agents // {
        hermes-desktop = prev.llm-agents.hermes-desktop.overrideAttrs (old: {
          env = (old.env or { }) // {
            NODE_OPTIONS = "--max-old-space-size=6144";
          };
        });
      };
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [

        {
          nixpkgs.overlays = [
            llm-agents.overlays.shared-nixpkgs
            hermesDesktopHeapOverlay
            grok-bot.overlays.default
            zenBrowserOverlay
            # KEYPOINT (review): splice the flake package only.
            # neomacs.overlays.default replaces rust/wpewebkit for the
            # whole package set; we do not want that.
            # (final: prev: {
            #   neomacs = neomacs.packages.${system}.neomacs;
            # })
            nix-openclaw.overlays.default
          ];
        }

        hyprland.nixosModules.default
        codex-desktop-linux.nixosModules.default
        ./hosts/nixos/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # 升级/重新激活时若文件内容冲突，先备份旧文件而不是中止激活。
          # 之前 home-manager-zi.service 反复因 ~/.ssh/config 冲突而激活失败。
          home-manager.backupFileExtension = "backup";
          home-manager.users.zi = {
            imports = [
              nix-openclaw.homeManagerModules.openclaw
              ./hosts/nixos/home.nix
            ];
          };
          home-manager.extraSpecialArgs = { inherit hyprland; };
        }
      ];
    };
  };
}
