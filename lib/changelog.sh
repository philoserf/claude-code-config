#!/usr/bin/env bash
# The CHANGELOG heading grammar, in one place. Sourced by lib/profile.sh (the
# version fallback, and through it gate check 11) and by the ship's
# extract-changelog.sh, so a heading the gate passes is always one the ship can
# turn into release notes.
#
# A heading is a line starting "## ". Its version is the text after that, with a
# leading "[" and then a leading "v" dropped, up to the first space, tab or "]".
# So `## 1.2.0`, `## 1.2.0 - 2026-03-08`, `## v1.2.0 — 2026-03-08`,
# `## [1.2.0] - 2026-03-08` and `## [v1.2.0]` all name 1.2.0, and `## Unreleased`
# names no release. Versions compare as literal strings, never as regexes: dots
# cannot act as wildcards, and 1.2.30 never answers for 1.2.3.
#
#   changelog_section VERSION FILE  prints that version's body: everything up to
#                                   the next heading, surrounding blank lines
#                                   trimmed. Returns 1 when there is no such
#                                   section or no such file.
#   changelog_latest FILE           prints the version of the first heading whose
#                                   whole version is a semver (X.Y.Z, then any
#                                   prerelease or build suffix): the newest
#                                   release, and always one changelog_section
#                                   finds. `## 1.2.3, 2026` names no release.
#                                   Returns 1 when there is none.

_changelog_awk() { # mode want file
  [ -f "$3" ] || return 1
  awk -v mode="$1" -v want="$2" '
    function version_of(line,   v) {
      v = substr(line, 4)
      sub(/^\[/, "", v)
      sub(/^v/, "", v)
      sub(/[[:space:]].*$/, "", v)
      sub(/\].*$/, "", v)
      return v
    }
    /^## / {
      v = version_of($0)
      if (mode == "latest") {
        if (v ~ /^[0-9]+\.[0-9]+\.[0-9]+[A-Za-z0-9.+-]*$/) { print v; found = 1; exit }
        next
      }
      if (inside) exit                 # the next heading ends the section
      if (v == want) { inside = 1; next }
    }
    inside { body = body $0 "\n" }
    END {
      if (mode == "latest") exit !found
      if (!inside) exit 1
      sub(/^\n+/, "", body)
      sub(/\n+$/, "", body)
      print body
    }
  ' "$3"
}

changelog_section() { _changelog_awk section "${1#v}" "$2"; }
changelog_latest() { _changelog_awk latest "" "$1"; }
