#!/usr/bin/env bash
# removed-names.sh <fixed-point>
#
# The mechanical half of "a removal is swept by its vocabulary": every name the diff
# since <fixed-point> stopped declaring, and every place the tree still mentions it.
#
# A name is one declared on a removed line of `git diff <fixed-point>...HEAD`:
#   Go   func, method, type, const, var, an exported struct field or const-block member
#   TS   function, const, let, class, interface, type
#   CLI  a flag declared with set.Bool/String/Int/Var("name", ...) or quoted "--name",
#        and a subcommand from a removed `case "name":`
# A name still declared somewhere in the tree was moved or kept, not removed, and is
# dropped. Mentions are searched outside history: CHANGELOG*, docs/adr/, THEORY.md,
# WALKTHROUGH.md and testdata/. A declared name is kept only when it is exported
# (Capitalised) or camelCase: a lowercase single word (note, create) is also English, and
# a word search for it is noise. Names shorter than four characters are skipped too.
#
# Prints "name: file:line: text" per mention. These are candidates for a reviewer to
# read, not verdicts: a removed field named Version still matches another type's Version.
# Exits 1 when any mention remains, 0 when none does, 2 on usage or git errors.

set -uo pipefail

fp=${1:-}
if [ -z "$fp" ]; then
  echo "usage: removed-names.sh <fixed-point>" >&2
  exit 2
fi
git rev-parse --verify --quiet "$fp" >/dev/null || { echo "removed-names.sh: no such ref: $fp" >&2; exit 2; }

removed=$(git diff "$fp"...HEAD -- . ':(exclude)**/testdata/**' | grep -E '^-[^-]' | cut -c2-)

names=$(
  {
    # Go declarations.
    printf '%s\n' "$removed" | sed -nE 's/^[[:space:]]*func[[:space:]]+(\([^)]*\)[[:space:]]*)?([A-Za-z_][A-Za-z0-9_]*).*/\2/p'
    printf '%s\n' "$removed" | sed -nE 's/^[[:space:]]*(type|const|var)[[:space:]]+([A-Za-z_][A-Za-z0-9_]*).*/\2/p'
    # Exported struct fields and const-block members: an indented capitalised name and a type or value.
    printf '%s\n' "$removed" | sed -nE 's/^[[:space:]]+([A-Z][A-Za-z0-9_]*)[[:space:]]+[][*A-Za-z=].*/\1/p'
    # TS declarations.
    printf '%s\n' "$removed" | sed -nE 's/^[[:space:]]*(export[[:space:]]+)?(default[[:space:]]+)?(function|const|let|class|interface|type)[[:space:]]+([A-Za-z_$][A-Za-z0-9_$]*).*/\4/p'
  } | awk 'length($0) >= 4 && ($0 ~ /^[A-Z]/ || $0 ~ /[a-z][A-Z]/)' | sort -u
)

flags=$(
  {
    printf '%s\n' "$removed" | sed -nE 's/.*set\.(Bool|String|Int|Var|Duration|Float64)\(("[^"]*",[[:space:]]*)?"([a-z][a-z0-9-]*)".*/\3/p'
    printf '%s\n' "$removed" | grep -oE '"--[a-z][a-z0-9-]+"' | tr -d '"' | sed 's/^--//'
    printf '%s\n' "$removed" | sed -nE 's/^[[:space:]]*case[[:space:]]+"([a-z][a-z0-9-]+)":.*/\1/p'
  } | awk 'length($0) >= 4' | sort -u
)

history=(':(exclude)*CHANGELOG*' ':(exclude)docs/adr/**' ':(exclude)**/THEORY.md' ':(exclude)**/WALKTHROUGH.md' ':(exclude)**/testdata/**')

found=0

for n in $names; do
  # Still declared somewhere: moved or kept, not removed.
  # (git grep -E has no \b, so an end is a non-word character or the line's end.)
  e='([^A-Za-z0-9_]|$)'
  if git grep -qE "(func[[:space:]]+(\([^)]*\)[[:space:]]*)?$n$e|(^|[^A-Za-z0-9_])(type|const|var|function|class|interface|let)[[:space:]]+$n$e|^[[:space:]]+$n[[:space:]]+[][*A-Za-z=]|^[[:space:]]+$n\()" -- . "${history[@]}"; then
    continue
  fi
  hits=$(git grep -nw "$n" -- . "${history[@]}")
  if [ -n "$hits" ]; then
    found=1
    printf '%s\n' "$hits" | sed "s/^/$n: /"
  fi
done

for f in $flags; do
  # A flag or subcommand the code still quotes, however it is declared, was kept.
  if git grep -qF -e "\"$f\"" -- '*.go' '*.ts' '*.js' "${history[@]}"; then
    continue
  fi
  hits=$(git grep -nF -e "--$f" -- . "${history[@]}")
  if [ -n "$hits" ]; then
    found=1
    printf '%s\n' "$hits" | sed "s/^/--$f: /"
  fi
done

exit "$found"
