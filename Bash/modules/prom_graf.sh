#!/usr/bin/env bash

PROMETHEUS_VERSION="3.10.0"
GRAFANA_VERSION="13.2.0"
PROMETHEUS_ARCHIVE="/tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
GRAFANA_ARCHIVE="/tmp/grafana-enterprise_${GRAFANA_VERSION}_linux_amd64.tar.gz"

download() {
    wget -O "$PROMETHEUS_ARCHIVE" "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" || return 1
    wget -O "$GRAFANA_ARCHIVE" "https://dl.grafana.com/grafana-enterprise/release/${GRAFANA_VERSION}/grafana-enterprise_${GRAFANA_VERSION}_32077357341_linux_amd64.tar.gz" || return 1
}

extract() {
    mkdir -p /opt || return 1
    tar -xzf "$PROMETHEUS_ARCHIVE" -C /opt || return 1
    tar -xzf "$GRAFANA_ARCHIVE" -C /opt || return 1
}

clean() {
    rm -f "$PROMETHEUS_ARCHIVE" "$GRAFANA_ARCHIVE"
}

run_prom_graf() {
    log_info "=== Prometheus and Grafana ==="

    if [[ "$DRY_RUN" == true ]]; then
        log_info "Dry-run enabled. Skipping monitoring downloads and startup."
        return 0
    fi

    download || { log_error "Monitoring download failed."; return 1; }
    extract || { log_error "Monitoring extraction failed."; return 1; }
    clean

    local prometheus_dir="/opt/prometheus-${PROMETHEUS_VERSION}.linux-amd64"
    local prometheus_bin="$prometheus_dir/prometheus"
    local grafana_bin
    grafana_bin=$(find /opt -maxdepth 4 -type f -name grafana -print -quit)

    if [[ ! -x "$prometheus_bin" ]]; then
        log_error "Prometheus binary not found: $prometheus_bin"
        return 1
    fi
    if [[ -z "$grafana_bin" || ! -x "$grafana_bin" ]]; then
        log_error "Grafana binary was not found under /opt."
        return 1
    fi

    log_info "Starting Prometheus and Grafana..."
    nohup "$prometheus_bin" --config.file="$prometheus_dir/prometheus.yml" >/var/log/prometheus.log 2>&1 &
    nohup "$grafana_bin" server >/var/log/grafana.log 2>&1 &
}