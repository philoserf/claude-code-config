# Analysis: Array Iteration

## Safe Patterns

### 1. Array Creation from Command

```bash
# SAFE: mapfile/readarray
mapfile -t lines < <(command)

# UNSAFE: Word splitting
lines=$(command)  # Splits on whitespace!
```

### 2. Safe Iteration

```bash
# SAFE: Quoted expansion
for item in "${array[@]}"; do
    echo "$item"
done

# UNSAFE: Unquoted
for item in ${array[@]}; do  # Word splitting!
    echo "$item"
done
```

### 3. Array Length

```bash
${#array[@]}  # Number of elements
${#array[0]}  # Length of first element
```

### 4. Indexed Iteration

```bash
for i in "${!array[@]}"; do
    echo "[$i] = ${array[$i]}"
done
```

## Edge Cases

Document in `edge-cases.md`:

- Empty arrays
- Elements with spaces
- Elements with special characters
- Sparse arrays

## References

- [patterns-and-conventions.md](../../patterns-and-conventions.md)
