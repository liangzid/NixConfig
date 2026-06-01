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
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codewhale = {
      url = "github:Hmbown/CodeWhale";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, emacs-overlay, hermes-agent, codewhale, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [

        {
          nixpkgs.overlays = [ emacs-overlay.overlays.default ];
        }

        hyprland.nixosModules.default
        ./hosts/nixos/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.zi = import ./hosts/nixos/home.nix;
          home-manager.extraSpecialArgs = { inherit hyprland hermes-agent codewhale; };
        }
      ];
    };
  };
}
