# Dry-Run Mode Usage

## Why Dry-Run?

Test deployment safely without making changes:

- Validate logic
- Check permissions
- Verify paths
- Test on production safely

## Using Dry-Run

```bash
# Test what would happen
./script.sh --dry-run production

# Review output, then run for real
./script.sh production
```

## Output Example

```text
[2024-01-03 12:00:00] [INFO] Starting deployment to: production
[2024-01-03 12:00:00] [INFO] Dry-run mode: true
[2024-01-03 12:00:01] [INFO] [DRY-RUN] Would execute: Create backup
[2024-01-03 12:00:01] [INFO] [DRY-RUN] Command: mkdir -p /tmp/backup
[2024-01-03 12:00:01] [INFO] [DRY-RUN] Would execute: Deploy files
```

## Best Practices

1. Always dry-run first
2. Review logs carefully
3. Test on staging before production
4. Keep dry-run output identical to real run (except for actual execution)
