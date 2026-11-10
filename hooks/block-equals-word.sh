#!/usr/bin/env bash
# PreToolUse hook (Bash): an unquoted word that begins with `=` and has more after
# it. The tool shell is zsh, which reads such a word as `=cmd` expansion: `echo ==`
# fails with "= not found" and the rest of the command aborts (see
# ~/.claude/CLAUDE.md, Environment). The rule is mechanical, so it lives here rather
# than as prose the model may skip.
#
# Where it can, the hook quotes the word and lets the command run: `echo =====`
# becomes `echo "====="`, which prints the same thing and costs no retry. It
# returns the rewritten input with no permission decision, so the call goes
# through the normal permission flow. Where quoting is not plainly safe — the same
# word also sits inside a quoted string, a heredoc or a comment, where rewriting
# would change what is printed — it blocks as before: exit 2 feeds stderr to the
# model. Fail-open: missing jq or perl, or an unparsable payload, lets it through.
#
# Before looking it removes what zsh does not expand there: heredoc bodies, quoted
# strings, comments, and `[[ ]]` and `(( ))`, where `==` is an operator. A lone `=`,
# as in `[ a = b ]`, is not expanded and passes.

command -v jq >/dev/null || exit 0
command -v perl >/dev/null || exit 0
payload=$(cat) || exit 0
cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0

# Prints "ok<TAB>rewritten" when every hit can be quoted in place, "block<TAB>word"
# when one cannot, and nothing when there is no hit.
verdict=$(printf '%s' "$cmd" | perl -0777 -ne '
  my $orig = $_;
  my $s = $_;
  $s =~ s/<<-?[ \t]*([\x27"]?)(\w+)\1[^\n]*\n.*?\n\t*\2[ \t]*(?=\n|\z)//gs;
  $s =~ s/\x27[^\x27]*\x27//g;
  $s =~ s/"(?:[^"\\]|\\.)*"//gs;
  $s =~ s/\[\[.*?\]\]//gs;
  $s =~ s/\(\(.*?\)\)//gs;
  $s =~ s/(^|[ \t])#[^\n]*/$1/gm;
  my %hits;
  $hits{$1} = 1 while $s =~ /(?:^|[\s;&|(])(=[^\s;&|)]+)/mg;
  exit 0 unless %hits;
  my $out = $orig;
  for my $h (sort keys %hits) {
    my $re = qr/(^|[\s;&|(])(\Q$h\E)(?=$|[\s;&|)])/m;
    my $n_s = () = $s =~ /$re/g;
    my $n_o = () = $orig =~ /$re/g;
    if ($n_s != $n_o || $h =~ /["\x27\\`\$]/) { print "block\t$h"; exit 0 }
    $out =~ s/$re/$1"$2"/g;
  }
  print "ok\t$out";
' 2>/dev/null) || exit 0
[ -z "$verdict" ] && exit 0

kind=${verdict%%$'\t'*}
rest=${verdict#*$'\t'}

if [ "$kind" = "ok" ]; then
  printf '%s' "$payload" | jq -c --arg c "$rest" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", updatedInput: (.tool_input | .command = $c)}}' \
    2>/dev/null || exit 0
  exit 0
fi

echo "Blocked: the unquoted word '$rest' begins with '=', which zsh expands as =cmd and fails with '= not found'. Quote it (\"$rest\") or use a different separator, such as ---." >&2
exit 2
