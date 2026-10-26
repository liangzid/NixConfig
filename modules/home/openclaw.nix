# ======================================================================
# OPENCLAW
#
# 1. Declarative OpenClaw gateway via official nix-openclaw Home Manager
#    module: Telegram DMs only, Nix-managed workspace, secrets on disk.
# 2. flake.nix overlay + homeManagerModules.openclaw
#      -> this module (programs.openclaw)
#      -> systemd --user openclaw-gateway (Linger=yes => boot)
# 3. 26 October 2026: first wiring. Workspace mapped from
#    ~/Documents/hermes-backup.tar.gz (Nous Hermes), not copied wholesale.
#    Model/provider left unset on purpose.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 26 October 2026
# ======================================================================

{ config, ... }:
let
  home = config.home.homeDirectory;
  telegramTokenFile = "${home}/.secrets/openclaw-telegram.token";
  gatewayTokenFile = "${home}/.secrets/openclaw-gateway.token";
in
{
  programs.openclaw = {
    enable = true;
    installApp = false;
    systemd.enable = true;

    # KEYPOINT (review): systemd user env does not load ~/.bashrc.local.
    # Values that are existing files are read at gateway start (not _FILE).
    environment = {
      OPENCLAW_GATEWAY_TOKEN = gatewayTokenFile;
    };

    workspace.bootstrapFiles = {
      agents = ./openclaw/workspace/AGENTS.md;
      soul = ./openclaw/workspace/SOUL.md;
      tools = ./openclaw/workspace/TOOLS.md;
      identity = ./openclaw/workspace/IDENTITY.md;
      user = ./openclaw/workspace/USER.md;
    };

    config = {
      gateway.mode = "local";

      channels.telegram = {
        enabled = true;
        tokenFile = telegramTokenFile;
        dmPolicy = "allowlist";
        allowFrom = [ 8306956528 ];
        groupPolicy = "disabled";
      };

      # Telegram account must have an agent owner or the channel stays blocked.
      bindings = [
        {
          agentId = "main";
          match = {
            channel = "telegram";
            accountId = "default";
          };
        }
      ];
    };
  };

  # KEYPOINT (review): upstream instance unit has no Install.WantedBy.
  # Without this, linger would still not start the gateway at boot.
  systemd.user.services.openclaw-gateway.Install.WantedBy = [ "default.target" ];
}
