{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    eamcs-overlay.url = "github:nix-community/emacs-overlay";
    codewhale = {
      url = "github:Hmbown/CodeWhale";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, emacs-overlay, codewhale, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system}.extend (final: prev: {
      reasonix = final.callPackage ./modules/packages/reasonix.nix { };
    });
  in {
    packages.${system} = {
      inherit (pkgs) reasonix;
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [

        {
          nixpkgs.overlays = [
            emacs-overlay.overlays.default
            (final: prev: {
              reasonix = final.callPackage ./modules/packages/reasonix.nix { };
            })
          ];
        }

        hyprland.nixosModules.default
        ./hosts/nixos/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.zi = import ./hosts/nixos/home.nix;
          home-manager.extraSpecialArgs = { inherit hyprland codewhale; };
        }
      ];
    };
  };
}
