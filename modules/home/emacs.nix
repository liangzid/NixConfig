{ config, pkgs, ... }: {
  programs.emacs = {
    enable = true;
    # nixpkgs 稳定 PGTK，走 cache.nixos.org；不用 emacs-overlay 的 unstable。
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      epkgs.vterm
      # KEYPOINT (review): grammars only; do not remap python/rust/nix
      # to *-ts-mode. Those hooks still use the classic major modes.
      epkgs.treesit-grammars.with-all-grammars
    ];
  };
}
