{ config, pkgs, ... }: {
  programs.emacs = {
    enable = true;
    # nixpkgs 稳定 PGTK，走 cache.nixos.org；不用 emacs-overlay 的 unstable。
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      epkgs.vterm
    ];
  };
}
