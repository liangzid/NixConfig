# ======================================================================
# DEVIN-DESKTOP
#
# 1. Install Cognition Devin Desktop (Windsurf rebrand). nixpkgs pins
#    a tarball URL; upstream only keeps the current stable build, so
#    older pins 404 (nixpkgs#592672).
# 2. This overlay replaces src/version, then systemPackages installs
#    pkgs.devin-desktop. Refresh from:
#      https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest
# 3. 25 November 2026: nixos-unstable still had 3.12.59 (404). Overlay
#    to the live 3.14.30833 tarball.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 25 November 2026
# ======================================================================

{ pkgs, ... }:
let
  # KEYPOINT (review): do not use the nixpkgs-pinned URL. Cognition
  # deletes old tarballs; only this "latest" pair is known to 200.
  version = "3.14.30833";
  vscodeVersion = "1.141.2";
  src = pkgs.fetchurl {
    url = "https://windsurf-stable.codeiumdata.com/linux-x64/stable/a165b2eb0a68542b92a3c89cc68b4700e819a409/Devin-linux-x64-3.14.30833.tar.gz";
    hash = "sha256-c1+A+aeFHAQ7ehlZWjlqP5NSYpquOIsa9aqGgGSpPGo=";
  };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      devin-desktop = prev.devin-desktop.overrideAttrs (old: {
        inherit version vscodeVersion src;
      });
    })
  ];

  environment.systemPackages = [ pkgs.devin-desktop ];
}
