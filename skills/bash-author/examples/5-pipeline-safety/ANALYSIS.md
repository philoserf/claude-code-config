# Analysis: Pipeline Safety

## The Problem

File names can contain:

- Spaces: `my file.txt`
- Newlines: `file\nwith\nnewlines.txt`
- Special chars: `file*?.txt`

Naive iteration breaks:

```bash
# UNSAFE - breaks on spaces
for file in $(find . -name "*.txt"); do
    rm "$file"  # Fails on "my file.txt"
done
```

## Safe Patterns

### 1. NULL-Delimited Find with While Loop

```bash
while IFS= read -r -d '' file; do
    # Process "$file"
done < <(find . -type f -print0)
```

- `-print0`: Output NUL-separated paths
- `-d ''`: Read until NUL character
- `IFS=`: Preserve whitespace
- `-r`: Don't interpret backslashes

### 2. Find with xargs -0

```bash
find . -type f -print0 | xargs -0 command
```

- `-print0`: NUL-separated output
- `xargs -0`: Read NUL-separated input

### 3. Array with Glob

```bash
files=("$dir"/*)
for file in "${files[@]}"; do
    # Process "$file"
done
```

- Always quote: `"${files[@]}"`
- Preserves spaces in filenames

## Test Data

See `test-data/` for files with:

- Spaces in names
- Special characters
- Edge cases

## References

- [patterns-and-conventions.md](../../patterns-and-conventions.md)
