#!/bin/bash
exec > ../docs/system_info
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
ip a | grep -Eo "inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]{1,2}"

echo
echo "Default Route:"
ip route | grep -Eo "default via [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"

echo
echo "DNS Configuration:"
grep -Ei "^(nameserver|search|domain)" /etc/resolv.conf

echo
echo "Listening Ports:"
ss -tuln


echo
echo "Services"
echo "========"

echo "Running Services:"
systemctl list-units --type=service --state=running

echo
echo "Failed Services:"
systemctl --failed


echo
echo "Security"
echo "========"

echo "SELinux Status:"
getenforce

echo
echo "Firewall Status:"
firewall-cmd --state


echo
echo "Package Management"
echo "==================="

echo "Installed Packages:"
dnf list installed | wc -l

echo
echo "Configured Repositories:"
dnf repolist


echo
echo "==================================="
echo "        Baseline Complete"
echo "==================================="