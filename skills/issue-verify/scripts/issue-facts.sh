#!/usr/bin/env bash
# shellcheck disable=SC2016  # backticks and $ in single quotes are literal Markdown or bash -c text, on purpose
# Gathers the mechanical facts needed to re-verify an issue against the current
# tree: which files and symbols it names, whether they still exist, what has
# touched them since the issue was filed, and what it is blocked by.
#
# It answers "are the issue's references still real", never "is the finding
# still valid". The second question is the skill's, not the script's.
#
# Usage: issue-facts.sh <ISSUE-NUMBER> [ISSUE-NUMBER...]
# Exit:  0 when every issue was read; 1 on usage error, or when any issue could
#        not be read (the rest are still reported).
#
# Output is grouped per issue and prefixed so it can be grepped:
#   FILE   present|MISSING   <path>
#   SYMBOL present|MISSING   <name>
#   SINCE  <n> commit(s) touched the named files since the filing commit
#   DEP    blocked_by #N
#
# A MISSING row is not automatically a stale issue — an issue may correctly name
# a file it is asking you to create, or a symbol it is asking you to delete.
# It is a prompt to read, not a verdict.

set -uo pipefail

command -v gh >/dev/null || { echo "issue-facts: gh not on PATH" >&2; exit 1; }
[ "$#" -ge 1 ] || { sed -n '3,22p' "$0" >&2; exit 1; }

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "issue-facts: not inside a git repository" >&2; exit 1; }
cd "$REPO_ROOT" || exit 1
rc=0

for n in "$@"; do
  json="$(gh issue view "$n" --json body,number,title,state,labels,milestone 2>/dev/null)" || {
    echo "issue-facts: cannot read issue #$n" >&2; rc=1; continue; }
  body="$(printf '%s' "$json" | jq -r .body)"
  meta="$(printf '%s' "$json" | jq -r '"#\(.number) [\(.state)] \(.milestone.title // "no milestone") [\(.labels|map(.name)|join(","))]\n\(.title)"')"

  echo "═══ $meta"

  # Referenced paths: backticked tokens ending in a known source extension, with
  # any :line or :line-range suffix stripped.
  #
  # Keyed on an extension list rather than "contains a dot", because prose in
  # these issues is full of backticked things that are not paths: a constant like
  # `-0.8333`, a qualified field like `SunEvent.Duration`, a version like `v4.1.0`.
  # Matching any dot reports all three as MISSING files and buries the real rows.
  paths="$(printf '%s' "$body" \
    | grep -oE '`[A-Za-z0-9_./-]+\.(go|md|ya?ml|json|js|ts|tsx|sh|py|rb|rs|toml|mod|sum|txt|css|html)(:[0-9]+(-[0-9]+)?)?`' \
    | tr -d '`' | sed 's/:[0-9].*$//' | sort -u \
    | grep -v '^\.issues/')"

  touched=()
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if [ -e "$p" ]; then
      echo "FILE   present   $p"
      touched+=("$p")
    else
      echo "FILE   MISSING   $p"
    fi
  done <<< "$paths"

  # Referenced symbols: backticked bare identifiers. Filtered to things that
  # plausibly name code — no dots, no slashes, not a lone keyword.
  syms="$(printf '%s' "$body" \
    | grep -oE '`[A-Za-z_][A-Za-z0-9_]{2,}`' \
    | tr -d '`' | sort -u \
    | grep -vExi 'true|false|null|nil|the|and|not|for|err|int|string|bool|float|error|func|type|const|var|make|len|cap|map|any' \
    | grep -vE '^[0-9a-f]{7,40}$')"

  while IFS= read -r s; do
    [ -n "$s" ] || continue
    if git grep -qwI -- "$s" >/dev/null 2>&1; then
      echo "SYMBOL present   $s"
    else
      echo "SYMBOL MISSING   $s"
    fi
  done <<< "$syms"

  # The filing commit, from the footer convention:
  #   _Filed from `.issues/x.md` at commit `abc1234`._
  filed="$(printf '%s' "$body" | grep -oE 'at commit `[0-9a-f]{7,40}`' | head -1 \
            | grep -oE '[0-9a-f]{7,40}')"
  if [ -n "$filed" ] && git cat-file -e "${filed}^{commit}" 2>/dev/null; then
    if [ "${#touched[@]}" -gt 0 ]; then
      c="$(git log --oneline "${filed}..HEAD" -- "${touched[@]}" 2>/dev/null | wc -l | tr -d ' ')"
      echo "SINCE  filed at $filed; $c commit(s) touched its files since"
      git log --oneline "${filed}..HEAD" -- "${touched[@]}" 2>/dev/null | sed 's/^/       /'
    else
      echo "SINCE  filed at $filed; no existing files to compare"
    fi
  else
    echo "SINCE  no filing commit in the body footer"
  fi

  # The endpoint returns full issue objects, state included. gh prints an API
  # error body on stdout, so a failure is read from the exit status, not the output.
  if ! deps="$(gh api "repos/{owner}/{repo}/issues/$n/dependencies/blocked_by" \
      --jq '.[] | "#\(.number) [\(.state | ascii_upcase)]"' 2>/dev/null)"; then
    echo "DEP    could not read blocked_by"
  elif [ -n "$deps" ]; then
    printf '%s\n' "$deps" | sed 's/^/DEP    blocked_by /'
  else
    echo "DEP    none"
  fi
  echo
done
exit "$rc"
