# ======================================================================
# WRAP-TZ
#
# 1. Wrap selected binaries so JS/ICU report America/Los_Angeles + en-US,
#    while NixOS time.timeZone stays Asia/Hong_Kong and the session
#    locale stays en_HK (waybar / date / fcitx).
# 2. Callers pass { pkg, bins, extraFlags ? [] }.
#      Desktop Exec=/nix/store/.../bin/foo is rewritten to Exec=foo so
#      wofi hits the wrapper (Chrome was bypassing TZ entirely).
# 3. 23 November 2026: TZ-only wrap left LANG=en_HK, so sites showed
#    US time + HK language. Also wrap LANG/LC_* and browser --lang.
#
# Author: Zi Liang <zi1415926.liang@connect.polyu.hk>
# Copyright © 2026, Zi Liang, all rights reserved.
# Created: 23 November 2026
# ======================================================================

# KEYPOINT (review): Pacific, not Eastern. extraLocales must include
# en_US.UTF-8 or LANG=en_US.UTF-8 is a missing locale.
{ pkgs, lib }:
{
  pkg,
  bins,
  extraFlags ? [ ],
}:
let
  tz = "America/Los_Angeles";
  lang = "en_US.UTF-8";
  extraFlagArgs = lib.concatMapStringsSep " " (
    flag: "--add-flags ${lib.escapeShellArg flag}"
  ) extraFlags;
in
pkgs.symlinkJoin {
  name = "${pkg.pname or pkg.name}-tz-${tz}";
  paths = [ pkg ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    ${lib.concatMapStringsSep "\n" (bin: ''
      if [ -e "$out/bin/${bin}" ]; then
        wrapProgram "$out/bin/${bin}" \
          --set TZ ${lib.escapeShellArg tz} \
          --set LANG ${lib.escapeShellArg lang} \
          --set LC_ALL ${lib.escapeShellArg lang} \
          --set LC_TIME ${lib.escapeShellArg lang} \
          --set LANGUAGE ${lib.escapeShellArg "en_US:en"} \
          ${extraFlagArgs}
      fi
    '') bins}

    if [ -d "$out/share/applications" ]; then
      tmp=$(mktemp -d)
      cp -aL "$out/share/applications/." "$tmp/"
      rm -rf "$out/share/applications"
      mkdir -p "$out/share/applications"
      cp -a "$tmp/." "$out/share/applications/"
      chmod -R u+w "$out/share/applications"
      for f in "$out/share/applications/"*.desktop; do
        [ -f "$f" ] || continue
        sed -i -E 's|^Exec=/nix/store/[^ /]+/bin/([^ ]+)|Exec=\1|' "$f"
      done
    fi
  '';
  meta = pkg.meta or { };
}
