#!/usr/bin/env bash
#
# Production Deployment Script Example
#
# Demonstrates real-world production patterns:
# - Logging
# - Dry-run mode
# - Configuration validation
# - Idempotency
# - Progress reporting
#
# References:
# - All ../ documents

set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
readonly LOG_FILE="${LOG_FILE:-/tmp/${SCRIPT_NAME}.log}"

# State
DRY_RUN=false
VERBOSE=false

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info()  { log "INFO" "$@"; }
log_warn()  { log "WARN" "$@"; }
log_error() { log "ERROR" "$@" >&2; }

# Execute command with logging and dry-run support
execute() {
    local description="$1"
    shift

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would execute: $description"
        log_info "[DRY-RUN] Command: $*"
        return 0
    fi

    log_info "Executing: $description"
    if [[ "$VERBOSE" == true ]]; then
        log_info "Command: $*"
    fi

    if "$@"; then
        log_info "✓ Success: $description"
        return 0
    else
        log_error "✗ Failed: $description"
        return 1
    fi
}

# Validate prerequisites
validate_prerequisites() {
    log_info "Validating prerequisites..."

    local -a required_commands=("git" "ssh")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done

    log_info "✓ All prerequisites met"
}

# Main deployment logic
deploy() {
    local target="$1"

    log_info "Starting deployment to: $target"
    log_info "Dry-run mode: $DRY_RUN"
    log_info "Log file: $LOG_FILE"
    echo

    # Step 1: Validate
    validate_prerequisites

    # Step 2: Backup (idempotent)
    execute "Create backup" mkdir -p /tmp/backup

    # Step 3: Deploy
    execute "Deploy files" echo "Deploying to $target"

    # Step 4: Verify
    log_info "Deployment complete!"
    log_info "Review log: $LOG_FILE"
}

usage() {
    cat >&2 <<EOF
Usage: $SCRIPT_NAME [OPTIONS] <target>

Production deployment script with logging and safety features.

OPTIONS:
    --dry-run       Show what would be done without executing
    --verbose       Enable verbose output
    -h, --help      Show this help

ARGUMENTS:
    target          Deployment target (production|staging)

EXAMPLES:
    $SCRIPT_NAME --dry-run production
    $SCRIPT_NAME --verbose staging

EOF
}

main() {
    local target=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                echo "Error: Unknown option: $1" >&2
                exit 1
                ;;
            *)
                target="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$target" ]]; then
        echo "Error: target is required" >&2
        usage
        exit 1
    fi

    deploy "$target"
}

main "$@"
