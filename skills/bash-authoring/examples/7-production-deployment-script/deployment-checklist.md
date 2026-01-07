# Deployment Checklist

## Pre-Deployment

- [ ] Code reviewed and approved
- [ ] Tests passing
- [ ] Dry-run executed successfully
- [ ] Staging deployment successful
- [ ] Backup created
- [ ] Rollback plan documented

## During Deployment

- [ ] Monitor logs in real-time
- [ ] Watch for errors
- [ ] Verify each step completes
- [ ] Check application health

## Post-Deployment

- [ ] Verify application running
- [ ] Run smoke tests
- [ ] Check logs for errors
- [ ] Monitor metrics
- [ ] Document any issues
- [ ] Notify stakeholders

## Rollback Procedure

If deployment fails:

1. Stop deployment immediately
2. Restore from backup
3. Verify rollback successful
4. Investigate failure
5. Document root cause
