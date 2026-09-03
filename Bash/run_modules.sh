#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log_info()  { echo "[INFO]  $*"; }
log_warn()  { echo "[WARN]  $*"; }
log_error() { echo "[ERROR] $*"; }
log_debug() { echo "[DEBUG] $*"; }

DRY_RUN=false
VERBOSE=false
AUTO_UPGRADE=false
overall_status=0

usage() {
    printf 'Usage: %s [--dry-run] [--verbose] [--auto-upgrade]\n' "$(basename "$0")"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --verbose) VERBOSE=true ;;
        --auto-upgrade) AUTO_UPGRADE=true ;;
        -h|--help) usage; exit 0 ;;
        *) log_error "Unknown option: $1"; usage >&2; exit 2 ;;
    esac
    shift
done

for m in "$SCRIPT_DIR"/modules/*.sh; do
    echo "=== Sourcing $m ==="
    source "$m"
done

for name in packages users ssh firewall permissions services logging prom_graf; do
    fn="run_${name}"
    if declare -f "$fn" > /dev/null; then
        echo ""
        echo "##### Running $name #####"
        if ! "$fn"; then
            log_error "$name failed"
            overall_status=1
        fi
    else
        echo "!!! $fn not found, skipping $name !!!"
    fi
done

echo ""
echo "Done."
exit "$overall_status"
