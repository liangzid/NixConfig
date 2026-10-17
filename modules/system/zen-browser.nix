# ======================================================================
# ZEN-BROWSER
#
# 1. Install Zen Browser with declarative Firefox policies (extensions,
#    telemetry, search engines, locked prefs).
# 2. flake.nix overlay (youwen5/zen-browser-flake)
#      -> this module (pkgs.zen-browser.override)
#      -> environment.systemPackages
#    MIME defaults: hosts/nixos/home.nix
#    Super+B:       dotfiles/hypr/hyprland.lua
# 3. 17 October 2026: initial setup from NixOS Wiki wrapFirefox example,
#    but override the flake-wrapped package instead of wrapping unwrapped.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 17 October 2026
# ======================================================================

{
  pkgs,
  lib,
  ...
}:
let
  # AMO shortId (URL slug) + guid (from addons.mozilla.org/api/v5/addons/addon/<shortId>/).
  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  prefs = {
    "extensions.autoDisableScopes" = 0;
    "extensions.pocket.enabled" = false;
  };

  extensions = [
    (extension "ublock-origin" "uBlock0@raymondhill.net")
    (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
    (extension "sponsorblock" "sponsorBlocker@ajay.app")
  ];

  extraPrefs = lib.concatLines (
    lib.mapAttrsToList (
      name: value: ''lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});''
    ) prefs
  );

  extraPolicies = {
    # KEYPOINT (review): wrapper overwrites unwrapped policies.json, so
    # DisableAppUpdate must be restated here or Zen will nag to self-update.
    DisableAppUpdate = true;
    DisableTelemetry = true;
    ExtensionSettings = builtins.listToAttrs extensions;
    SearchEngines = {
      Default = "Google";
      Add = [
        {
          Name = "nixpkgs packages";
          URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
          IconURL = "https://wiki.nixos.org/favicon.ico";
          Alias = "@np";
        }
        {
          Name = "NixOS options";
          URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
          IconURL = "https://wiki.nixos.org/favicon.ico";
          Alias = "@no";
        }
        {
          Name = "NixOS Wiki";
          URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
          IconURL = "https://wiki.nixos.org/favicon.ico";
          Alias = "@nw";
        }
        {
          Name = "noogle";
          URLTemplate = "https://noogle.dev/q?term={searchTerms}";
          IconURL = "https://noogle.dev/favicon.ico";
          Alias = "@ng";
        }
      ];
    };
  };
in
{
  environment.systemPackages = [
    (pkgs.zen-browser.override {
      inherit extraPrefs extraPolicies;
    })
  ];
}
