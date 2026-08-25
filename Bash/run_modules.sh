#!/usr/bin/env bash
# Simplest possible runner: log functions + run every module.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

log_info()  { echo "[INFO]  $*"; }
log_warn()  { echo "[WARN]  $*"; }
log_error() { echo "[ERROR] $*"; }
log_debug() { echo "[DEBUG] $*"; }

DRY_RUN=false
VERBOSE=false
AUTO_UPGRADE=false

for m in "$SCRIPT_DIR"/modules/*.sh; do
    echo "=== Sourcing $m ==="
    source "$m"
done

for name in packages users ssh firewall permissions storage services logging; do
    fn="run_${name}"
    if declare -f "$fn" > /dev/null; then
        echo ""
        echo "##### Running $name #####"
        "$fn"
    else
        echo "!!! $fn not found, skipping $name !!!"
    fi
done

echo ""
echo "Done."
