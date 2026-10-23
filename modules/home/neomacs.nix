# ======================================================================
# NEOMACS
#
# 1. Install eval-exec/neomacs beside GNU emacs-pgtk; do not replace it.
# 2. flake.nix overlay splices neomacs.packages.x86_64-linux.neomacs
#      -> this module (NVIDIA VK_DRIVER_FILES wrapper)
#      -> home.packages
# 3. 19 October 2026: first setup. Upstream wrap --set-default
#    VK_DRIVER_FILES to mesa; outer --set points at the NVIDIA ICD.
#    22 October 2026: drop bin/emacs and bin/emacsclient so home-manager
#    buildEnv does not collide with programs.emacs (emacs-pgtk).
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 19 October 2026
# ======================================================================

{
  pkgs,
  ...
}:
let
  # KEYPOINT (review): this host's ICD is nvidia_icd.json, not
  # nvidia_icd.x86_64.json. /run/opengl-driver is the NixOS graphics
  # driver link after hardware.graphics.enable.
  nvidiaVulkanIcd = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";

  wrapBinIfPresent = out: name: ''
    if [ -x "${out}/bin/${name}" ]; then
      wrapProgram "${out}/bin/${name}" --set VK_DRIVER_FILES ${nvidiaVulkanIcd}
    fi
  '';

  neomacs = pkgs.symlinkJoin {
    name = "neomacs";
    paths = [ pkgs.neomacs ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      ${wrapBinIfPresent "$out" "neomacs"}
      ${wrapBinIfPresent "$out" "neomacsclient"}
      # KEYPOINT (review): upstream ships emacs -> neomacs and
      # emacsclient -> neomacsclient. GNU emacs-pgtk must keep those names.
      rm -f "$out/bin/emacs" "$out/bin/emacsclient"
    '';
  };
in {
  home.packages = [ neomacs ];
}
