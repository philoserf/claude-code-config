#!/usr/bin/env bash
# Fixture tests for release-tag.sh, the step that creates the release tag. It is
# the one public step in the release that cannot be undone, so its refusals are the
# point: each case below is a way the tag could land on a commit no gate saw.
#
# Two stand-ins reach it from a throwaway repo. RELEASE_CHECK swaps the real gate
# for a stub, because a fixture can never pass the real one (no remote to fetch,
# nothing for `bun audit`). A stub `gh` first on PATH answers the merged-PR lookup
# with whatever MERGE_OID holds. Neither the real gate nor the real gh is covered.
#
# Usage: tests/release-tag.sh

set -uo pipefail

TAGGER="$(cd "$(dirname "$0")/.." && pwd)/scripts/release-tag.sh"
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  FAIL %s\n         %s\n' "$1" "$2"; }
check() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1" "want '$3', got '$2'"; fi; }
has()   { if printf '%s' "$2" | grep -qE -- "$3"; then ok "$1"; else bad "$1" "no '$3' in: $2"; fi; }

# A global tag.gpgSign would sign `git tag 1.0.0` and die on "no tag message?";
# the identity lets every fixture commit. Same reason as exit-codes.sh.
export GIT_CONFIG_COUNT=3 GIT_CONFIG_KEY_0=tag.gpgSign GIT_CONFIG_VALUE_0=false \
  GIT_CONFIG_KEY_1=user.name GIT_CONFIG_VALUE_1=Test \
  GIT_CONFIG_KEY_2=user.email GIT_CONFIG_VALUE_2=t@example.com

WORK="$(mktemp -d "${TMPDIR:-/tmp}/release-tag.XXXXXX")"
trap 'cd /; rm -rf "$WORK"' EXIT

# Stub gate: exits with GATE_EXIT (default 0), as release-check.sh would.
cat >"$WORK/gate" <<'GATEEOF'
#!/usr/bin/env bash
echo "Result: stub gate"
exit "${GATE_EXIT:-0}"
GATEEOF
# Stub gh: answers `gh pr list --json mergeCommit` as GitHub would, with one
# merged PR whose merge is MERGE_OID, or none (`[]`) when MERGE_OID is unset.
mkdir "$WORK/bin"
cat >"$WORK/bin/gh" <<'GHEOF'
#!/usr/bin/env bash
if [ -n "${MERGE_OID:-}" ]; then
  printf '[{"mergeCommit":{"oid":"%s"}}]\n' "$MERGE_OID"
else
  echo '[]'
fi
GHEOF
chmod +x "$WORK/gate" "$WORK/bin/gh"
export RELEASE_CHECK="$WORK/gate" PATH="$WORK/bin:$PATH"

# A Node repo at 1.0.0, tagged, with a bare origin. `github` points origin's URL
# at github.com so the plan says is_github=1; pushes still go to the bare repo.
repo() { # [github] -> path
  local d o; d="$(mktemp -d "$WORK/repo.XXXXXX")"; o="$d.origin"
  git init -q --bare "$o"
  git -C "$d" init -q -b main
  echo '{"name":"fx","version":"1.0.0"}' >"$d/package.json"
  git -C "$d" add -A && git -C "$d" commit -qm init && git -C "$d" tag 1.0.0
  git -C "$d" remote add origin "$o"
  git -C "$d" push -q origin main
  [ "${1:-}" = github ] && git -C "$d" remote set-url origin git@github.com:fx/fx.git \
    && git -C "$d" remote set-url --push origin "$o"
  echo "$d"
}

# The prep branch, pushed, bumping to 1.1.0.
prep() { # dir
  git -C "$1" checkout -q -b release/1.1.0
  echo '{"name":"fx","version":"1.1.0"}' >"$1/package.json"
  git -C "$1" commit -qam "chore: prepare release 1.1.0"
  git -C "$1" push -q "$(git -C "$1" remote get-url --push origin)" release/1.1.0:release/1.1.0
  git -C "$1" fetch -q "$(git -C "$1" remote get-url --push origin)" \
    '+refs/heads/*:refs/remotes/origin/*'
  git -C "$1" checkout -q main
}

run() { # dir -> output; exit code in CODE
  OUT="$(cd "$1" && "$TAGGER" 1.1.0 2>&1)"; CODE=$?
}
tagged() { git -C "$1" rev-parse -q --verify refs/tags/1.1.0 >/dev/null && echo yes || echo no; }

squash() { # dir subject -> squash-merges the prep branch onto main
  git -C "$1" merge -q --squash release/1.1.0 >/dev/null
  git -C "$1" commit -qm "$2"
}

echo "release-tag: the gate"

D="$(repo)"; prep "$D"; squash "$D" "chore: prepare release 1.1.0"
GATE_EXIT=1 run "$D"
check "gate not green: exits 1" "$CODE" "1"
check "gate not green: no tag" "$(tagged "$D")" "no"
has "gate not green: gate output shown" "$OUT" "stub gate"

echo
echo "release-tag: off GitHub"

D="$(repo)"; prep "$D"; squash "$D" "chore: prepare release 1.1.0 (#7)"
run "$D"
check "squash with the prep subject: exits 0" "$CODE" "0"
check "squash with the prep subject: tags HEAD" \
  "$(git -C "$D" rev-parse -q --verify '1.1.0^{commit}')" "$(git -C "$D" rev-parse HEAD)"
check "squash with the prep subject: annotated" "$(git -C "$D" cat-file -t 1.1.0)" "tag"

D="$(repo)"; prep "$D"; git -C "$D" merge -q --no-ff -m "Merge branch 'release/1.1.0'" release/1.1.0
run "$D"
check "merge commit of the prep branch: exits 0" "$CODE" "0"
check "merge commit of the prep branch: tagged" "$(tagged "$D")" "yes"

D="$(repo)"; prep "$D"; squash "$D" "Release 1.1.0"
run "$D"
check "reworded squash subject: exits 1" "$CODE" "1"
check "reworded squash subject: no tag" "$(tagged "$D")" "no"
has "reworded squash subject: says no prep merge" "$OUT" "No prep merge found"

# No prep branch was pushed and HEAD is no merge, so both sides of the
# second-parent comparison are empty. Empty must not equal empty.
D="$(repo)"; git -C "$D" commit -q --allow-empty -m "unrelated"
run "$D"
check "no prep ref and no merge: exits 1" "$CODE" "1"
check "no prep ref and no merge: no tag" "$(tagged "$D")" "no"

echo
echo "release-tag: on GitHub"

# The lookup keys on the prep branch, so a reworded squash subject still tags.
D="$(repo github)"; prep "$D"; squash "$D" "Release 1.1.0"
MERGE_OID="$(git -C "$D" rev-parse HEAD)" run "$D"
check "PR merge is HEAD: exits 0" "$CODE" "0"
check "PR merge is HEAD: tagged" "$(tagged "$D")" "yes"

D="$(repo github)"; prep "$D"; squash "$D" "chore: prepare release 1.1.0 (#7)"
M="$(git -C "$D" rev-parse HEAD)"
git -C "$D" commit -q --allow-empty -m "landed after the prep merge"
MERGE_OID="$M" run "$D"
check "commits after the PR merge: exits 1" "$CODE" "1"
check "commits after the PR merge: no tag" "$(tagged "$D")" "no"
has "commits after the PR merge: lists them" "$OUT" "landed after the prep merge"
has "commits after the PR merge: says ask, do not pick" "$OUT" "do not choose one"

# A prep subject on HEAD does not stand in for the PR on GitHub.
D="$(repo github)"; prep "$D"; squash "$D" "chore: prepare release 1.1.0"
run "$D"
check "no merged PR: exits 1" "$CODE" "1"
check "no merged PR: no tag" "$(tagged "$D")" "no"
has "no merged PR: says no prep merge" "$OUT" "No prep merge found"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
