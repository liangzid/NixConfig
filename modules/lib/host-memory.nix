# ======================================================================
# HOST-MEMORY
#
# 1. Derive nix max-jobs / cores from this machine's RAM so parallel
#    C++/Rust/Node builds cannot OOM the desktop session.
# 2. Callers pass { hostDir }. hostDir is hosts/nixos/; the script writes
#    `{ totalMemKb = …; }` to detected-memory.nix from /proc/meminfo.
#    Do not pass ./detected-memory.nix as a path literal: flakes error if
#    that file is missing. Nix itself cannot read /proc (pure eval forbids
#    it; even --impure readFile returns empty because fstat size is 0).
#    Missing / unreadable file → 16 GiB fallback. Rebuild script also
#    imports this file (no nixpkgs) so THIS switch uses the same jobs.
# 3. 24 November 2026: 8 jobs × cores=0 OOMed a 16 GB laptop during
#    Hyprland + llm-agents rebuilds. Comments had claimed 31 GB.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 24 November 2026
# ======================================================================

{ hostDir }:

let
  fallbackMemKb = 16 * 1024 * 1024;
  detectedFile = hostDir + "/detected-memory.nix";

  # KEYPOINT (review): flake eval only sees git-staged files. The rebuild
  # script git add -f's detected-memory.nix; without that, pathExists is
  # false and we use 16 GiB — safer than the old max-jobs=8.
  readDetectedMemKb = path:
    if builtins.pathExists path
    then (import path).totalMemKb or fallbackMemKb
    else fallbackMemKb;

  kbToGiB = kb: kb / 1024 / 1024;

  minInt = a: b: if a < b then a else b;
  maxInt = a: b: if a > b then a else b;

  desktopReserveGiB = 4;
  ramPerJobGiB = 4;
  maxJobsCap = 4;
  coresPerJob = 4;

  computeMaxJobs = totalMemGiB:
    let
      buildGiB =
        if totalMemGiB > desktopReserveGiB
        then totalMemGiB - desktopReserveGiB
        else 1;
    in
      maxInt 1 (minInt maxJobsCap (buildGiB / ramPerJobGiB));

  totalMemKb = readDetectedMemKb detectedFile;
  totalMemGiB = kbToGiB totalMemKb;
in
{
  inherit totalMemKb totalMemGiB;
  maxJobs = computeMaxJobs totalMemGiB;
  cores = coresPerJob;
}
