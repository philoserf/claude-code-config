#!/usr/bin/env bash
# shellcheck disable=SC2016  # payload commands are literal text in single quotes, on purpose
# Tests for the PreToolUse hooks in hooks/, through their real interface: a JSON
# payload on stdin, an exit code out (0 lets the call through, 2 blocks it) and,
# on a block, the reason on stderr.
#
# Each hook runs under `bash`, as settings.json runs it, so it gets the BSD grep
# and sed it gets in production. Typing a command at the tool shell is no test of
# a hook: there grep is ugrep, which disagrees on edge cases (see CLAUDE.md).
#
# guard-git-commit.sh's branch rule applies only to repos under $HOME/source, so
# its cases run with HOME pointed at a throwaway directory holding fixture repos.
# That section comes last, since everything after it inherits the fake HOME.
#
# settings.json hands block-pr-fill.sh only commands matching `gh pr create *`.
# The hook does its own matching too, and its cases test that matching on any
# command.
#
# Usage: tests/hooks.sh

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS="$ROOT/hooks"

PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  FAIL %s\n         %s\n' "$1" "$2"; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

payload() { # command [cwd] -> the Bash tool's PreToolUse JSON
  jq -n --arg c "$1" --arg d "${2:-$TMP}" '{tool_name: "Bash", tool_input: {command: $c}, cwd: $d}'
}

# run HOOK PAYLOAD: sets CODE and ERR.
run() {
  ERR=$(printf '%s' "$2" | bash "$HOOKS/$1" 2>&1 >/dev/null)
  CODE=$?
}

passes() { # hook command [cwd]
  run "$1" "$(payload "$2" "${3:-}")"
  if [ "$CODE" = 0 ]; then ok "passes: $2"; else bad "passes: $2" "exit $CODE: $ERR"; fi
}

blocks() { # hook command expected-stderr-prefix [cwd]
  run "$1" "$(payload "$2" "${4:-}")"
  if [ "$CODE" = 2 ] && [ "${ERR#"$3"}" != "$ERR" ]; then ok "blocks: $2"
  else bad "blocks: $2" "exit $CODE, stderr: $ERR"; fi
}

fails_open() { # hook raw-stdin label
  run "$1" "$2"
  if [ "$CODE" = 0 ]; then ok "fails open: $3"; else bad "fails open: $3" "exit $CODE: $ERR"; fi
}

echo "block-bare-runtimes.sh"
HOOK=block-bare-runtimes.sh
blocks $HOOK 'python3 x.py'                 'Blocked: bare python3.'
blocks $HOOK 'python -c 1'                  'Blocked: bare python.'
blocks $HOOK 'pip install x'                'Blocked: bare pip.'
blocks $HOOK 'ls; npx biome'                'Blocked: bare npx.'
blocks $HOOK 'cat a | pip3 install -r -'    'Blocked: bare pip3.'
blocks $HOOK 'echo $(python3 -V)'           'Blocked: bare python3.'
blocks $HOOK $'cd /tmp\npython y.py'        'Blocked: bare python.'
blocks $HOOK 'true && python3'              'Blocked: bare python3.'
blocks $HOOK '(python3 -V)'                 'Blocked: bare python3.'
blocks $HOOK 'bunx x || npx x'              'Blocked: bare npx.'
passes $HOOK 'uv run python x.py'
passes $HOOK 'command -v python3'
passes $HOOK 'bunx biome check'
passes $HOOK 'pythonista --help'
passes $HOOK 'git commit -m "drop npx"'
fails_open $HOOK 'not json'                 'unparsable payload'
fails_open $HOOK '{}'                       'no command'

echo
echo "block-pr-fill.sh"
HOOK=block-pr-fill.sh
FILL='Blocked: gh pr create --fill'
blocks $HOOK 'gh pr create --fill'                  "$FILL"
blocks $HOOK 'gh pr create -f'                      "$FILL"
blocks $HOOK 'gh pr create --fill-first'            "$FILL"
blocks $HOOK 'gh pr create --base main --fill-verbose' "$FILL"
blocks $HOOK 'cd repo && gh pr create --fill'       "$FILL"
blocks $HOOK $'git push\ngh pr create --fill'      "$FILL"
blocks $HOOK '(gh pr create -f)'                    "$FILL"
blocks $HOOK 'gh pr create --fill=true'             "$FILL"
passes $HOOK 'gh pr create --title t --body-file b.md'
passes $HOOK 'gh pr create --title t --body b; rm -f b.md'
passes $HOOK 'git commit -m "never gh pr create --fill"'
passes $HOOK 'gh pr view --fill'
fails_open $HOOK 'not json'                         'unparsable payload'
fails_open $HOOK '{}'                               'no command'

echo
echo "guard-git-commit.sh"
HOOK=guard-git-commit.sh
CHAIN='Blocked: this commit runs whether or not the check'

# Rule 2, a check chained to the commit by ';' or a newline. $TMP is no repo,
# so rule 1 has nothing to say and only rule 2 decides.
blocks $HOOK 'task; git commit -m x'                "$CHAIN"
blocks $HOOK $'go test ./...\ngit commit -m x'      "$CHAIN"
blocks $HOOK 'task check && git add -u; git commit -m x' "$CHAIN"
blocks $HOOK '(task test); git commit -m x'         "$CHAIN"
blocks $HOOK 'echo $(task check); git commit -m x'  "$CHAIN"
blocks $HOOK 'go test ./...; git commit -m x'       "$CHAIN"
passes $HOOK 'task && git commit -m x'
passes $HOOK 'go test ./... && git add -u && git commit -m x'
passes $HOOK 'git add -u; git commit -m x'
passes $HOOK 'echo task; git commit -m x'
passes $HOOK 'taskset=1; git commit -m x'
passes $HOOK 'git commit -m x; task'

# Rule 1, a commit on the default branch of a repo under ~/source. HOME is the
# physical path: git reports a repo's top level with symlinks resolved, and on
# macOS $TMP sits under the /var -> /private/var link.
export GIT_CONFIG_COUNT=2 GIT_CONFIG_KEY_0=user.name GIT_CONFIG_VALUE_0=Test \
  GIT_CONFIG_KEY_1=user.email GIT_CONFIG_VALUE_1=t@example.com
FAKE_HOME="$(cd "$TMP" && pwd -P)/home"
repo() { # dir branch
  mkdir -p "$1" && git -C "$1" init -q -b "$2" && git -C "$1" commit -q --allow-empty -m init
}
repo "$FAKE_HOME/source/x" main
repo "$FAKE_HOME/source/trunky" trunk
git -C "$FAKE_HOME/source/trunky" update-ref refs/remotes/origin/trunk HEAD
git -C "$FAKE_HOME/source/trunky" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/trunk
repo "$FAKE_HOME/elsewhere" main
ON_MAIN='Blocked: a commit on main'
export HOME="$FAKE_HOME"

blocks $HOOK 'git commit -m x'                      "$ON_MAIN" "$FAKE_HOME/source/x"
blocks $HOOK 'cd ~/source/x && git commit -m x'     "$ON_MAIN" "$TMP"
blocks $HOOK 'cd source/x && git commit -m x'       "$ON_MAIN" "$FAKE_HOME"
blocks $HOOK "cd \"$FAKE_HOME/source/x\" && git commit -m x" "$ON_MAIN" "$TMP"
blocks $HOOK '(cd ~/source/x && git commit -m x)'   "$ON_MAIN" "$TMP"
blocks $HOOK 'cd ~/source/x; git commit -m x'       "$ON_MAIN" "$TMP"
blocks $HOOK 'git commit -m x'                      'Blocked: a commit on trunk' "$FAKE_HOME/source/trunky"
passes $HOOK 'git status'                           "$FAKE_HOME/source/x"
passes $HOOK 'git commit -m x'                      "$FAKE_HOME/elsewhere"
passes $HOOK 'cd ~/elsewhere && git commit -m x'    "$FAKE_HOME/source/x"
git -C "$FAKE_HOME/source/x" switch -q -c feature
passes $HOOK 'git commit -m x'                      "$FAKE_HOME/source/x"
git -C "$FAKE_HOME/source/x" switch -q --detach
passes $HOOK 'git commit -m x'                      "$FAKE_HOME/source/x"
fails_open $HOOK 'not json'                         'unparsable payload'
fails_open $HOOK '{}'                               'no command'
fails_open $HOOK '{"tool_input": {"command": "git commit -m x"}}' 'no cwd and no cd'

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
