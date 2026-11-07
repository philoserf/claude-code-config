#!/usr/bin/env bash
# PreToolUse hook (Bash): block an unquoted word that begins with `=` and has more
# after it. The tool shell is zsh, which reads such a word as `=cmd` expansion:
# `echo ==` fails with "= not found" and the rest of the command aborts (see
# ~/.claude/CLAUDE.md, Environment). The rule is mechanical, so it lives here rather
# than as prose the model may skip. Exit 2 blocks the call and feeds stderr to the
# model. Fail-open: missing jq or perl, or an unparsable payload, lets it through.
#
# Before looking it removes what zsh does not expand there: heredoc bodies, quoted
# strings, comments, and `[[ ]]` and `(( ))`, where `==` is an operator. A lone `=`,
# as in `[ a = b ]`, is not expanded and passes.

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0
command -v perl >/dev/null || exit 0

hit=$(printf '%s\n' "$cmd" | perl -0777 -ne '
  s/<<-?[ \t]*([\x27"]?)(\w+)\1[^\n]*\n.*?\n\t*\2[ \t]*(?=\n|\z)//gs;
  s/\x27[^\x27]*\x27//g;
  s/"(?:[^"\\]|\\.)*"//gs;
  s/\[\[.*?\]\]//gs;
  s/\(\(.*?\)\)//gs;
  s/(^|[ \t])#[^\n]*/$1/gm;
  print $1 if /(?:^|[\s;&|(])(=[^\s;&|)]+)/m;
' 2>/dev/null) || exit 0
[ -z "$hit" ] && exit 0

echo "Blocked: the unquoted word '$hit' begins with '=', which zsh expands as =cmd and fails with '= not found'. Quote it (\"$hit\") or use a different separator, such as ---." >&2
exit 2
