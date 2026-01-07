# Analysis: Parameter Validation

## Overview

This example demonstrates **comprehensive parameter validation** strategies. Proper validation prevents errors, provides clear feedback, and makes scripts robust and user-friendly.

## Key Validation Patterns

### 1. Required vs Optional Parameters

**Required parameters** must be provided:

```bash
if [[ -z "$input_file" ]]; then
    echo "Error: --input is required" >&2
    exit 1
fi
```

**Optional parameters** have defaults:

```bash
local count=1          # Default value
local format="json"    # Default value
```

### 2. Type Validation

**Positive integer check**:

```bash
is_positive_integer() {
    local value="$1"
    [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -gt 0 ]]
}
```

### 3. Range Validation

```bash
is_in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    [[ "$value" -ge "$min" ]] && [[ "$value" -le "$max" ]]
}
```

### 4. Enum/List Validation

```bash
is_in_list() {
    local value="$1"
    shift
    local allowed=("$@")
    # Check if value in allowed list
}
```

### 5. File Validation

**Check existence**:

```bash
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file does not exist: $input_file" >&2
    exit 1
fi
```

**Check readability**:

```bash
if [[ ! -r "$input_file" ]]; then
    echo "Error: Input file is not readable: $input_file" >&2
    exit 1
fi
```

**Prevent overwrite**:

```bash
if [[ -e "$output_file" ]]; then
    echo "Error: Output file already exists: $output_file" >&2
    exit 1
fi
```

**Check directory writable**:

```bash
output_dir="$(dirname "$output_file")"
if [[ ! -w "$output_dir" ]]; then
    echo "Error: Output directory is not writable: $output_dir" >&2
    exit 1
fi
```

## Error Message Best Practices

1. **Be specific**: Include actual value received
2. **Be helpful**: Suggest what to do
3. **Use stderr**: Error messages go to `>&2`
4. **Show usage**: Call `usage` function after error

## Testing

```bash
# Valid usage
./script.sh --input test.txt --output out.txt

# Test missing required param
./script.sh --output out.txt
# Error: --input is required

# Test invalid count
./script.sh --input test.txt --output out.txt --count 150
# Error: --count must be between 1 and 100, got: 150

# Test invalid format
./script.sh --input test.txt --output out.txt --format pdf
# Error: --format must be one of: json xml csv, got: pdf
```

## References

- [patterns-and-conventions.md](../../patterns-and-conventions.md)
- [safety-and-security.md](../../safety-and-security.md)
