# ======================================================================
# THRONE
#
# 1. Install Throne (formerly NekoRay) with TUN privileges so VLESS
#    nodes can cover apps that ignore HTTP_PROXY (WeChat, QQ, Steam).
# 2. configuration.nix imports this module
#      -> programs.throne.enable installs pkgs.throne
#      -> tunMode wraps ThroneCore with cap_net_admin
#      -> GUI at runtime: wofi -> Throne (not autostarted)
# 3. 23 November 2026: replace clash-verge-rev. Nodes/subscriptions stay
#    out of git; HK-style routing (default DIRECT, AI via proxy) is
#    configured in the GUI using the domain list below.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 23 November 2026
# ======================================================================

# KEYPOINT (review): do not also add pkgs.throne to systemPackages.
# programs.throne.enable already installs it. tunMode.enable without
# enable does not apply the capability wrapper, and TUN then fails.
#
# GUI routing checklist (HK mode; not Nix-managed):
#   DIRECT: localhost, 127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12,
#           192.168.0.0/16, *.astaple.com
#   Proxy:  chatgpt.com, openai.com, anthropic.com, claude.ai,
#           oaistatic.com, oaiusercontent.com, intercom.io, intercomcdn.com
#   MATCH:  DIRECT
{
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  # TUN return traffic is dropped under strict rpfilter.
  networking.firewall.checkReversePath = "loose";

  # TUN often has ping-to-IP work while DNS fails. The throne module
  # also installs a polkit rule for resolved when this is on.
  services.resolved.enable = true;
}
