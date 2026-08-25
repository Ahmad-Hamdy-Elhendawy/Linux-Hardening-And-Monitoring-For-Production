#!/usr/bin/env bash
# System updates module

run_packages() {
    log_info "=== System Updates ==="

    # IMPORTANT: capture the exit code from the command itself, not from
    # the `if` test (which always reports 0/success for the taken branch).
    dnf check-update &>/dev/null
    local status=$?  # 0 = no updates, 100 = updates available, other = error

    if [[ $status -eq 100 ]]; then
        log_info "Updates are available."
        if [[ "$AUTO_UPGRADE" == true ]]; then
            log_info "Auto‑upgrade enabled. Installing updates..."
            if [[ "$DRY_RUN" != true ]]; then
                dnf update -y
            fi
            log_info "System updated."
        else
            log_warn "Updates available. Run with --auto-upgrade to install automatically."
            # Optionally, we could still prompt if stdin is a terminal, but we'll keep non‑interactive.
        fi
    elif [[ $status -eq 0 ]]; then
        log_info "System is up to date."
    else
        log_error "Failed to check for updates (exit code: $status)."
        exit 1
    fi
}