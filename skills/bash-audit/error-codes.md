# Common ShellCheck Error Codes

## SC1000-1099: Parser Errors

```bash
# SC1004: Backslash continuation not followed by newline
echo hello\
world  # Error - needs line continuation

# SC1008: Invalid data for operator `=='
if [[ $var =  "value" ]]; then  # Space before ==
    true
fi
```

## SC2000-2099: Shell Issues

```bash
# SC2009: Consider using pgrep or pidof instead of grep|grep
ps aux | grep -v grep | grep myprocess  # Use pgrep instead

# SC2012: Use `ls` only for viewing. Use `find` for reliable output
for file in $(ls -la)  # Better: use find or globbing

# SC2015: Avoid using && and || instead of if-then-else
[[ -f "$file" ]] && echo "found" || echo "not found"  # Less clear

# SC2016: Expressions don't expand in single quotes
echo '$VAR'  # Literal $VAR, not variable expansion

# SC2026: This word is non-standard. Set POSIXLY_CORRECT
# when using with scripts for other shells
```

## SC2100-2199: Quoting Issues

```bash
# SC2086: Double quote to prevent globbing and word splitting
for i in $list; do  # Should be: for i in $list or for i in "$list"
    echo "$i"
done

# SC2115: Literal tilde in path not expanded. Use $HOME instead
~/.bashrc  # In strings, use "$HOME/.bashrc"

# SC2181: Check exit code directly with `if`, not indirectly in a list
some_command
if [ $? -eq 0 ]; then  # Better: if some_command; then

# SC2206: Quote to prevent word splitting or set IFS
array=( $items )  # Should use: array=( $items )
```

## SC3000-3999: POSIX Compliance Issues

```bash
# SC3010: In POSIX sh, use 'case' instead of 'cond && foo'
[[ $var == "value" ]] && do_something  # Not POSIX

# SC3043: In POSIX sh, use 'local' is undefined
function my_func() {
    local var=value  # Not POSIX in some shells
}
```
