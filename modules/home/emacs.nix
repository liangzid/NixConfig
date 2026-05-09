{ config, pkgs, ... }: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-unstable-pgtk;
    extraPackages = epkgs: [
      epkgs.vterm
    ];
  };
}
