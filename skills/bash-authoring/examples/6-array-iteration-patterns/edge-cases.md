# Array Edge Cases

## Empty Arrays

```bash
array=()
echo "${#array[@]}"  # 0

# Safe iteration - loop body never executes
for item in "${array[@]}"; do
    echo "$item"  # Never runs
done
```

## Elements with Spaces

```bash
array=("item one" "item two")
for item in "${array[@]}"; do  # CORRECT: quotes preserve spaces
    echo "$item"
done

for item in ${array[@]}; do  # WRONG: splits "item one" into "item" and "one"
    echo "$item"
done
```

## Special Characters

```bash
array=('file*.txt' 'data?.csv')  # Single quotes prevent globbing
for item in "${array[@]}"; do
    echo "$item"  # Prints literal strings, no glob expansion
done
```

## Sparse Arrays

```bash
array[0]="first"
array[5]="sixth"  # Indices 1-4 don't exist
echo "${#array[@]}"  # 2 (only counts set elements)

for i in "${!array[@]}"; do
    echo "[$i] = ${array[$i]}"  # Only prints 0 and 5
done
```
