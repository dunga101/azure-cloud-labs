#!/usr/bin/env bash
set -euo pipefail

# Router configuration script for vm-router.
# Run this on the Ubuntu router VM.

echo "Updating package index and installing troubleshooting tools..."
sudo apt update
sudo apt install -y iptables traceroute tcpdump net-tools

echo "Enabling Linux kernel IPv4 forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
  echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
fi

echo "Configuring iptables forwarding and NAT..."
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -j ACCEPT

echo "Validation:"
sysctl net.ipv4.ip_forward
sudo iptables -L
sudo iptables -t nat -L

echo "Router setup complete."
