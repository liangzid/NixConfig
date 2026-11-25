# ======================================================================
# CODEX-DESKTOP
#
# 1. Install OpenAI Codex Linux Desktop from the official Linux .deb
#    (ilysenko/codex-desktop-linux). This is the GUI app, not the
#    llm-agents.codex CLI already on PATH.
# 2. flake.nix input + nixosModules.default
#      -> this module (programs.codexDesktopLinux.enable)
#      -> environment.systemPackages (codex-desktop)
#    Wayland: NIXOS_OZONE_WL is already set in hyprland.lua.
# 3. 25 November 2026: initial install. Do not set cliPackage: Desktop
#    keeps the CLI bundled in the official package; llm-agents.codex
#    remains the standalone terminal CLI.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 25 November 2026
# ======================================================================

# KEYPOINT (review): programs.codexDesktopLinux.enable already puts
# codex-desktop on PATH. Do not also add it to systemPackages.
{
  programs.codexDesktopLinux = {
    enable = true;
  };
}
