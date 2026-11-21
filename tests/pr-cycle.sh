#!/usr/bin/env bash
# Fixture tests for bin/pr-cycle: the local gate, which gate it runs when given
# none, the review ship and merge need, and open and merge end to end against a
# bare origin, with a stub gh standing in for GitHub.
#
# The gate is the only check before a merge, so its refusals matter most: a
# failing command, a tree dirty before the gate (it would test work that is not
# pushed), and a tree the gate leaves dirty (a formatter rewrote files).
#
# Usage: tests/pr-cycle.sh

set -uo pipefail

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (want '$3', got '$2')"; fi; }
commit(){ local dir="$1"; shift; git -C "$dir" -c user.name=t -c user.email=t@t commit -q "$@"; }

echo "local gate"
CYCLE="$(cd "$(dirname "$0")/.." && pwd)/bin/pr-cycle"
R="$(mktemp -d)"
git -C "$R" init -q && commit "$R" --allow-empty -m init
gate() { (cd "$R" && "$CYCLE" gate "$1" >/dev/null 2>&1); echo $?; }
check "a passing gate exits 0"              "$(gate true)"            "0"
check "a failing gate exits 4"              "$(gate false)"           "4"
check "a gate that dirties the tree exits 4" "$(gate 'touch fmt.txt')" "4"
check "a dirty tree refuses to gate (1)"    "$(gate true)"            "1"
rm -rf "$R"

# With no gate argument the gate is profile.sh's GATE_CMD. The Taskfile's
# `check` fails, so only the .release-gate override can make this pass.
echo "gate from the profile"
R="$(mktemp -d)"
git -C "$R" init -q
printf 'version: "3"\ntasks:\n  check:\n    cmds:\n      - "false"\n' >"$R/Taskfile.yml"
echo 'GATE_CMD="true"' >"$R/.release-gate"
git -C "$R" add -A && commit "$R" -m init
check "no argument runs the .release-gate override" "$(gate '')" "0"
rm -rf "$R"

R="$(mktemp -d)"
git -C "$R" init -q && commit "$R" --allow-empty -m init
check "no argument and no gate refuses (1)" "$(gate '')" "1"
rm -rf "$R"

# The files a branch adds against its base. A rename and an edit are not
# additions; a new file is, wherever it sits.
echo "added files"
R="$(mktemp -d)"
git -C "$R" init -q -b main
echo a >"$R/a.txt" && echo e >"$R/e.txt"
git -C "$R" add -A && commit "$R" -m init
git -C "$R" checkout -q -b work
git -C "$R" mv a.txt c.txt && echo more >>"$R/e.txt"
mkdir "$R/docs" && echo stray >"$R/docs/stray.rows"
git -C "$R" add -A && commit "$R" -m work
added() { (cd "$R" && PR_BASE=main "$CYCLE" added "$1" 2>/dev/null); }
check "a new file is listed, a rename and an edit are not" "$(added work)" "docs/stray.rows"
git -C "$R" checkout -q -b quiet main
commit "$R" --allow-empty -m nothing
check "a branch that adds nothing lists nothing" "$(added quiet)" ""
rm -rf "$R"

# ship opens and merges in one go, so it refuses a branch head nobody marked
# reviewed. Each case gates with a command that fails, so a ship that gets past
# the review check stops at the gate (4) and never reaches a push.
echo "review before ship"
R="$(mktemp -d)"
git -C "$R" init -q -b main
commit "$R" --allow-empty -m init
git -C "$R" checkout -q -b work
B="$(mktemp)"
ship() { (cd "$R" && "$CYCLE" ship work t "$B" "$1" >/dev/null 2>&1); echo $?; }
check "an unreviewed branch is refused (1)" "$(ship 'touch ran')" "1"
check "and the gate never ran" "$([ -e "$R/ran" ] && echo ran || echo not)" "not"
(cd "$R" && "$CYCLE" reviewed work >/dev/null)
check "a reviewed head passes to the gate (4)" "$(ship false)" "4"
commit "$R" --allow-empty -m more
check "a commit after the review is refused (1)" "$(ship false)" "1"
check "PR_CYCLE_UNREVIEWED passes to the gate (4)" \
  "$(cd "$R" && PR_CYCLE_UNREVIEWED="test" "$CYCLE" ship work t "$B" false >/dev/null 2>&1; echo $?)" "4"
rm -rf "$R" "$B"

# merge is run from any checkout, so it reads the PR from gh, refuses a head nobody
# reviewed or one GitHub holds that the review did not, and gates that head in a
# throwaway worktree. A stub gh first on PATH logs each call's arguments, quoted,
# to $GH_LOG and answers from fixtures: the PR's branch and head, a PR URL, and
# `repo view`'s JSON from $STUB_REPO_JSON put through the caller's own --jq, so
# merge_flag's filter runs for real. At `pr create` it also logs origin's work,
# which shows the push came first. The fixture has a bare origin, so a merge runs
# to the end.
command -v jq >/dev/null || { echo "jq is required"; exit 1; }
S="$(mktemp -d)"
cat >"$S/gh" <<'GHEOF'
#!/usr/bin/env bash
{ printf '%q ' "$@"; echo; } >>"$GH_LOG"
case "$*" in
  *headRefName*) echo work ;;
  *headRefOid*) echo "$STUB_HEAD" ;;
  "repo view"*)
    [ -n "${STUB_REPO_JSON:-}" ] || exit 1
    while [ "$#" -gt 0 ] && [ "$1" != --jq ]; do shift; done
    printf '%s' "$STUB_REPO_JSON" | jq -r "$2" ;;
  "pr create"*)
    echo "origin work at create: $(git --git-dir="$STUB_ORIGIN" rev-parse work)" >>"$GH_LOG"
    echo "https://github.com/o/r/pull/7" ;;
  "pr merge"*) : ;;
  *) exit 1 ;;
esac
GHEOF
chmod +x "$S/gh"
GH_LOG="$S/gh.log"
O="$S/origin.git"
called() { cat "$GH_LOG" 2>/dev/null | grep -c -- "$1"; }
gone() { git -C "$1" rev-parse -q --verify "refs/heads/$2" || echo gone; }

# fixture sets R to a clone of the bare origin O: main, and a branch work one
# commit ahead, both pushed.
fixture() {
  rm -rf "$O" "$S/repo" "$GH_LOG" "$S/gate-ran"
  git init -q --bare -b main "$O"
  git clone -q "$O" "$S/repo" 2>/dev/null
  R="$S/repo"
  git -C "$R" checkout -q -b main
  # shellcheck disable=SC2016 # The gate expands these when it runs, not this printf.
  printf 'GATE_CMD='\''[ -z "${FAIL_GATE:-}" ] && touch "$GATE_RAN"'\''\n' >"$R/.release-gate"
  git -C "$R" add -A && commit "$R" -m init
  git -C "$R" push -q origin main 2>/dev/null
  git -C "$R" remote set-head origin main
  git -C "$R" checkout -q -b work
  commit "$R" --allow-empty -m work
  git -C "$R" push -q origin work 2>/dev/null
  git -C "$R" checkout -q main
}
# with_stub <dir> [VAR=value...] <cmd...>: run in <dir> with the stub gh, a fresh
# log, and none of the caller's pr-cycle settings.
with_stub() {
  local dir="$1"; shift
  rm -f "$GH_LOG" "$S/gate-ran"
  (cd "$dir" && PATH="$S:$PATH" GH_LOG="$GH_LOG" GATE_RAN="$S/gate-ran" STUB_ORIGIN="$O" \
    STUB_HEAD="${HEAD_ON_GITHUB:-$(git -C "$R" rev-parse work)}" \
    env -u PR_BASE -u GH_REPO -u PR_CYCLE_UNREVIEWED -u PR_CYCLE_GATED "$@")
}
merge() { with_stub "$R" "$@" "$CYCLE" merge 7 >/dev/null 2>&1; echo $?; }
was() { [ -e "$S/$1" ] && echo yes || echo no; }

echo "review and gate before merge"
fixture
check "an unreviewed head is refused (1)" "$(merge)" "1"
check "and neither gated nor merged" "$(was gate-ran)$(called 'pr merge')" "no0"
(cd "$R" && "$CYCLE" reviewed work >/dev/null)
check "a failing gate stops the merge (4)" "$(merge FAIL_GATE=1)" "4"
check "and nothing was merged" "$(called 'pr merge')" "0"
check "a head GitHub holds that the review did not is refused (1)" \
  "$(HEAD_ON_GITHUB="$(git -C "$R" rev-parse main)" merge)" "1"
check "and nothing was merged" "$(called 'pr merge')" "0"
check "a reviewed head is gated, then merged (0)" "$(merge)" "0"
check "and the gate ran" "$(was gate-ran)" "yes"
check "no gate worktree is left behind" "$(git -C "$R" worktree list | wc -l | tr -d ' ')" "1"

echo "after the merge"
check "the checkout is back on the base" "$(git -C "$R" branch --show-current)" "main"
check "the local branch is deleted" "$(gone "$R" work)" "gone"
check "the remote branch is deleted" "$(gone "$O" work)" "gone"
fixture
HEAD_ON_GITHUB="$(git -C "$R" rev-parse main)" merge PR_CYCLE_UNREVIEWED=test >/dev/null
check "PR_CYCLE_UNREVIEWED gates and merges whatever GitHub holds" "$(was gate-ran)$(called 'pr merge')" "yes1"

# The repo decides how PRs land: the first method it allows, squash first, and
# squash when gh cannot say.
echo "merge method"
merge_flag_for() {
  fixture
  merge PR_CYCLE_UNREVIEWED=test STUB_REPO_JSON="$1" >/dev/null
  grep '^pr merge' "$GH_LOG" | grep -oE -- '--(squash|merge|rebase)'
}
check "squash when allowed" \
  "$(merge_flag_for '{"squashMergeAllowed":true,"mergeCommitAllowed":true,"rebaseMergeAllowed":true}')" "--squash"
check "merge when squash is not" \
  "$(merge_flag_for '{"squashMergeAllowed":false,"mergeCommitAllowed":true,"rebaseMergeAllowed":true}')" "--merge"
check "rebase when only rebase" \
  "$(merge_flag_for '{"squashMergeAllowed":false,"mergeCommitAllowed":false,"rebaseMergeAllowed":true}')" "--rebase"
check "squash when gh fails" "$(merge_flag_for '')" "--squash"

# A linked worktree cannot check out the base while the main checkout has it,
# so there merge detaches at origin's base and start branches from it. A commit
# only on the local base tells the two apart.
echo "linked worktree"
fixture
W="$S/wt"
git -C "$R" worktree add -q "$W" work 2>/dev/null
commit "$R" --allow-empty -m local-only
check "merge from a linked worktree exits 0" \
  "$(with_stub "$W" PR_CYCLE_UNREVIEWED=test "$CYCLE" merge 7 >/dev/null 2>&1; echo $?)" "0"
check "and detaches at origin's base, not the local one" \
  "$(git -C "$W" rev-parse HEAD)" "$(git -C "$R" rev-parse origin/main)"
check "and deletes the local branch" "$(gone "$R" work)" "gone"
check "and deletes the remote branch" "$(gone "$O" work)" "gone"
check "and leaves the main checkout on main" "$(git -C "$R" branch --show-current)" "main"
check "start from a linked worktree exits 0" \
  "$(with_stub "$W" "$CYCLE" start next >/dev/null 2>&1; echo $?)" "0"
check "and branches from origin's base, not the local one" \
  "$(git -C "$W" rev-parse next)" "$(git -C "$R" rev-parse origin/main)"
git -C "$R" worktree remove --force "$W"

echo "open"
fixture
B="$S/body.md"; echo body >"$B"
git -C "$R" checkout -q work
commit "$R" --allow-empty -m unpushed
git -C "$R" checkout -q main
check "open prints the PR URL" \
  "$(with_stub "$R" "$CYCLE" open work 'A title' "$B" 2>/dev/null)" "https://github.com/o/r/pull/7"
check "and asks gh for a PR from the branch onto the base" \
  "$(grep '^pr create' "$GH_LOG")" "pr create --base main --head work --title A\\ title --body-file $B "
check "and pushes the branch before it does" \
  "$(grep '^origin work at create' "$GH_LOG")" "origin work at create: $(git -C "$R" rev-parse work)"
check "a missing body file is refused (1)" \
  "$(with_stub "$R" "$CYCLE" open work t "$S/none" >/dev/null 2>&1; echo $?)" "1"
check "and gh is never called" "$(called 'pr create')" "0"
rm -rf "$S"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
