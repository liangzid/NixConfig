{
  # Root is a trusted user, so nixos-rebuild (sudo) honors this on the
  # first switch — before configuration.nix has rewritten nix.conf.
  nixConfig = {
    extra-substituters = [
      "https://eval-exec.cachix.org"
      "https://nix-wpe-webkit.cachix.org"
    ];
    extra-trusted-public-keys = [
      "eval-exec.cachix.org-1:xvopUI7X7+Vt1gaSsWJ0PQFPP66vs8v5iIaz6boxf64="
      "nix-wpe-webkit.cachix.org-1:ItCjHkz1Y5QcwqI9cTGNWHzcox4EqcXqKvOygxpwYHE="
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
    # Do not nixpkgs.follows: crane / rust-overlay / nix-wpe-webkit are
    # pinned to neomacs' own nixpkgs. Following ours forces a WPE rebuild.
    neomacs.url = "github:eval-exec/neomacs";
    # Do not nixpkgs.follows: nix-openclaw pins pnpm/qmd/tool packages.
    # Following ours would rebuild their toolchain against our nixpkgs.
    nix-openclaw.url = "github:openclaw/nix-openclaw";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, llm-agents, grok-bot, zen-browser, neomacs, nix-openclaw, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # KEYPOINT (review): youwen5 sources.json for 1.23.3b is stale.
    # GitHub re-uploaded zen.linux-x86_64.tar.xz after the flake hashed it.
    # specified: sha256-d9cHicsaxIhxd0FpzxdQdy6J62cfSiWHJO9F1pyIbxU=
    # actual:    sha256-uyBF0+IWVNQP6EElAJLurf0sH8gx7vtQkiJ3PIvcoUk=  (prefetch 2026-10-17)
    # Drop this overlay and use the flake's default package once upstream matches.
    zenBrowserTarballHash = "sha256-uyBF0+IWVNQP6EElAJLurf0sH8gx7vtQkiJ3PIvcoUk=";

    zenBrowserOverlay = final: prev: let
      unwrapped = zen-browser.packages.${system}.zen-browser-unwrapped.overrideAttrs (old: {
        src = prev.fetchurl {
          url = old.src.url or (builtins.head old.src.urls);
          hash = zenBrowserTarballHash;
        };
      });
    in {
      # Re-wrap after the src fix; wrapFirefox closes over unwrapped at call time.
      # Same firefoxVersion trick as youwen5/zen-browser.nix so FFmpeg ABI matches.
      zen-browser = prev.wrapFirefox (unwrapped // {
        version = unwrapped.firefoxVersion;
      }) {
        pname = "zen-browser";
        version = unwrapped.version;
      };
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [

        {
          nixpkgs.overlays = [
            llm-agents.overlays.shared-nixpkgs
            grok-bot.overlays.default
            zenBrowserOverlay
            # KEYPOINT (review): splice the flake package only.
            # neomacs.overlays.default replaces rust/wpewebkit for the
            # whole package set; we do not want that.
            (final: prev: {
              neomacs = neomacs.packages.${system}.neomacs;
            })
            nix-openclaw.overlays.default
          ];
        }

        hyprland.nixosModules.default
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
