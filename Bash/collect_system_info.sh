#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec > "$SCRIPT_DIR/../docs/system_info"
set -euo pipefail

echo "==================================="
echo "      Linux Server Baseline"
echo "==================================="

echo
echo "System Information"
echo "=================="

echo "Hostname:"
hostname

echo
echo "Operating System:"
cat /etc/os-release

echo
echo "Kernel Version:"
uname -r

echo
echo "Architecture:"
uname -m

echo
echo "Uptime:"
uptime


echo
echo "System Resources"
echo "================"

echo "CPU:"
lscpu

echo
echo "Memory:"
free -h

echo
echo "Disk / Filesystem Usage:"
df -h


echo
echo "Network Configuration"
echo "====================="

echo "IP Addresses:"
if command -v ip >/dev/null 2>&1; then
	ip a | grep -Eo "inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]{1,2}" || true
else
	echo "ip utility unavailable"
fi

echo
echo "Default Route:"
if command -v ip >/dev/null 2>&1; then
	ip route | grep -Eo "default via [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" || true
else
	echo "ip utility unavailable"
fi

echo
echo "DNS Configuration:"
grep -Ei "^(nameserver|search|domain)" /etc/resolv.conf || true

echo
echo "Listening Ports:"
if command -v ss >/dev/null 2>&1; then
	ss -tuln
else
	echo "ss utility unavailable"
fi


echo
echo "Services"
echo "========"

echo "Running Services:"
if command -v systemctl >/dev/null 2>&1; then
	systemctl list-units --type=service --state=running || true
else
	echo "systemctl unavailable"
fi

echo
echo "Failed Services:"
if command -v systemctl >/dev/null 2>&1; then
	systemctl --failed || true
else
	echo "systemctl unavailable"
fi


echo
echo "Security"
echo "========"

echo "SELinux Status:"
if command -v getenforce >/dev/null 2>&1; then
	getenforce
else
	echo "SELinux tools unavailable"
fi

echo
echo "Firewall Status:"
if command -v firewall-cmd >/dev/null 2>&1; then
	firewall-cmd --state || true
else
	echo "firewalld unavailable"
fi


echo
echo "Package Management"
echo "==================="

echo "Installed Packages:"
if command -v dnf >/dev/null 2>&1; then
	dnf list installed | wc -l || true
else
	echo "dnf unavailable"
fi

echo
echo "Configured Repositories:"
if command -v dnf >/dev/null 2>&1; then
	dnf repolist || true
else
	echo "dnf unavailable"
fi


echo
echo "==================================="
echo "        Baseline Complete"
echo "==================================="