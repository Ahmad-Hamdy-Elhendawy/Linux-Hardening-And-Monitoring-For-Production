#!/usr/bin/env bash

# System updates module

run_packages() {
    log_info "=== System Updates ==="

    # Check for available updates.
    # dnf check-update returns:
    # 0   = no updates available
    # 100 = updates are available
    # other = actual error

    dnf check-update &>/dev/null
    local status=$?

    if [[ $status -eq 100 ]]; then
        log_info "Updates are available."

        if [[ "$AUTO_UPGRADE" == true ]]; then
            log_info "Auto-upgrade enabled. Installing updates..."

            if [[ "$DRY_RUN" != true ]]; then
                if dnf update -y; then
                    log_info "System updated."
                else
                    log_error "Failed to update system."
                    return 1
                fi
            else
                log_info "Dry-run enabled. Skipping update."
            fi

        else
            log_warn "Updates available. Run with --auto-upgrade to install automatically."
        fi

    elif [[ $status -eq 0 ]]; then
        log_info "System is up to date."

    else
        log_error "Failed to check for updates (exit code: $status)."
        return 1
    fi
}