#!/usr/bin/env bash
# run "chmod +x RUN_THIS_FIRST_PERMISSIONS.sh"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;