#!/usr/bin/env bash

set -euo pipefail

download() {
    cd /tmp

    wget https://github.com/prometheus/prometheus/releases/download/v3.10.0/prometheus-3.10.0.linux-amd64.tar.gz

    wget https://dl.grafana.com/grafana-enterprise/release/13.2.0/grafana-enterprise_13.2.0_32077357341_linux_amd64.tar.gz
}

extract() {
    tar -xzf /tmp/prometheus*.tar.gz -C /opt
    tar -xzf /tmp/grafana*.tar.gz -C /opt
}

clean() {
    rm -f /tmp/prometheus*.tar.gz
    rm -f /tmp/grafana*.tar.gz
}

firewall() {
    firewall-cmd --permanent --add-port=3000/tcp
    firewall-cmd --permanent --add-port=9090/tcp
    firewall-cmd --reload
}

run() {
    /opt/prometheus-3.10.0.linux-amd64/prometheus &
    /opt/grafana-enterprise_13.2.0/bin/grafana &
}

download
extract
clean
firewall
run