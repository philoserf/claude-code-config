# Advanced Techniques

Advanced Bash patterns, dependency management, and common pitfalls to avoid.

## Advanced Error Handling

### Error Context and Stack Traces

```bash
trap 'echo "Error at line $LINENO: exit $?" >&2' ERR
```

Enhanced with function stack trace:

```bash
trap 'echo "Error in ${BASH_SOURCE[1]}:${BASH_LINENO[0]} (function: ${FUNCNAME[1]})" >&2' ERR
```

### Safe Temporary File Handling

```bash
trap 'rm -rf "$tmpdir"' EXIT
tmpdir=$(mktemp -d)
```

Multiple cleanup handlers:

```bash
cleanup() {
  rm -rf "$tmpdir"
  kill "$background_pid" 2>/dev/null || true
}
trap cleanup EXIT
```

## Advanced Variable Techniques

### Nameref Variables (Bash 4.3+)

Create references to other variables:

```bash
declare -n ref=varname
ref="value"  # Sets $varname to "value"
```

Useful for passing variables by reference to functions.

### Associative Arrays

Complex data structures:

```bash
declare -A config=(
  [host]="localhost"
  [port]="8080"
  [timeout]="30"
)

echo "${config[host]}"  # localhost
```

### Function Returns with Global Variables

Return complex data from functions:

```bash
process_data() {
  declare -g result="processed: $1"
  declare -g status=0
}

process_data "input"
echo "$result"  # processed: input
```

## Parameter Expansion

Advanced string manipulation:

```bash
filename="script.sh"
${filename%.sh}          # Remove extension: "script"
${filename##*/}          # Basename: "script.sh"
${filename%/*}           # Dirname
${text//old/new}         # Replace all occurrences
${text/#prefix/new}      # Replace prefix
${text/%suffix/new}      # Replace suffix
${var:offset:length}     # Substring
${#var}                  # Length
${var:-default}          # Use default if unset
${var:=default}          # Set default if unset
${var:?error message}    # Error if unset
${var:+alternative}      # Use alternative if set
```

Case conversion (Bash 4.0+):

```bash
${var^^}   # Uppercase
${var,,}   # Lowercase
${var^}    # Capitalize first character
```

## Signal Handling

Graceful shutdown on signals:

```bash
cleanup_function() {
  echo "Shutting down gracefully..." >&2
  # cleanup code
  exit 0
}

trap cleanup_function SIGHUP SIGINT SIGTERM
```

## Command Grouping and Subshells

Share redirection:

```bash
{
  cmd1
  cmd2
} > output.log 2>&1
```

Use subshell for isolation:

```bash
(
  cd /some/directory || exit
  do_work
)
# Still in original directory
```

## Co-processes (Advanced IPC)

Bidirectional communication:

```bash
coproc proc {
  while read -r line; do
    echo "Processed: $line"
  done
}

echo "data" >&"${proc[1]}"
read -u "${proc[0]}" result
echo "$result"  # Processed: data
```

## Here-documents

With tab stripping:

```bash
cat <<-'EOF'
  Indented content
  Tabs are stripped
EOF
```

Quoted delimiter prevents expansion:

```bash
cat <<'EOF'
  $variable is literal
EOF
```

## Process Management

Wait for specific background job:

```bash
command &
pid=$!
wait $pid
```

Wait for any background job (Bash 4.3+):

```bash
wait -n
```

List background PIDs:

```bash
jobs -p
```

## Conditional Execution

Chain commands:

```bash
cmd1 && cmd2           # Run cmd2 only if cmd1 succeeds
cmd1 || cmd2           # Run cmd2 if cmd1 fails
cmd1 && cmd2 || cmd3   # Run cmd2 if cmd1 succeeds, else cmd3
```

## Brace Expansion

Generate sequences efficiently:

```bash
touch file{1..10}.txt           # Creates file1.txt through file10.txt
mkdir -p project/{src,test,doc} # Creates multiple directories
echo {A..Z}                     # Prints A B C ... Z
```

## Parallel Execution

Process items in parallel:

```bash
xargs -P $(nproc) -n 1 command < input_list
```

Using GNU parallel (when available):

```bash
parallel -j $(nproc) command ::: arg1 arg2 arg3
```

## Structured Output

Generate JSON with jq:

```bash
jq -n --arg key "$value" '{key: $key}'
```

## Performance Profiling

Detailed timing:

```bash
TIMEFORMAT='real: %R, user: %U, system: %S'
time {
  # code to profile
}
```

See [performance-and-optimization.md](performance-and-optimization.md) for more profiling techniques.

## Dependency Management

### Package Managers

**basher**:

```bash
basher install username/repo@version
```

**bpkg**:

```bash
bpkg install username/repo -g
```

### Best Practices

- **Vendoring**: Copy dependencies into project for reproducible builds
- **Lock files**: Document exact versions of dependencies used
- **Checksum verification**: Verify integrity of sourced external scripts
- **Version pinning**: Lock dependencies to specific versions
- **Dependency isolation**: Use separate directories for different dependency sets
- **Update automation**: Automate dependency updates with Dependabot or Renovate
- **Security scanning**: Scan dependencies for known vulnerabilities

## Common Pitfalls to Avoid

### 1. Word Splitting and Globbing

**Problem**:

```bash
for f in $(ls *.txt); do  # WRONG: breaks on spaces
  process "$f"
done
```

**Solution**:

```bash
find . -name '*.txt' -print0 | while IFS= read -r -d '' f; do
  process "$f"
done
```

Or with globbing:

```bash
for f in *.txt; do
  [[ -e "$f" ]] || continue  # Skip if no matches
  process "$f"
done
```

### 2. Unquoted Variable Expansions

**Problem**:

```bash
rm -rf $dir  # WRONG: if $dir is empty, deletes everything
```

**Solution**:

```bash
rm -rf -- "$dir"
```

### 3. Relying Solely on `set -e`

`set -e` doesn't work in all contexts (within conditionals, pipelines, etc.)

**Solution**: Use explicit error checking and traps.

### 4. Using echo for Data Output

**Problem**: `echo` behavior varies across platforms.

**Solution**: Use `printf` for reliable output:

```bash
printf '%s\n' "$data"
```

### 5. Missing Cleanup Traps

**Problem**: Temporary files left behind on error.

**Solution**: Always use EXIT trap:

```bash
trap 'rm -rf "$tmpdir"' EXIT
tmpdir=$(mktemp -d)
```

### 6. Unsafe Array Population

**Problem**:

```bash
files=($(find . -name '*.txt'))  # Breaks on spaces, newlines
```

**Solution**:

```bash
readarray -d '' files < <(find . -name '*.txt' -print0)
```

### 7. Ignoring Binary-Safe File Handling

Always use NUL separators for filenames:

```bash
find . -print0 | while IFS= read -r -d '' file; do
  process "$file"
done
```
