#!/bin/bash
set -e
echo "[INFO] Creating Bridge and TAP interfaces..."

# 1. Create and enable the bridge
sudo ip link add br0 type bridge 2>/dev/null || true
sudo ip link set br0 up

# 2. Create TAP1 and attach to bridge
sudo ip tuntap add dev tap1 mode tap user $USER 2>/dev/null || true
sudo ip link set tap1 master br0
sudo ip link set tap1 up

# 3. Create TAP2 and attach to bridge
sudo ip tuntap add dev tap2 mode tap user $USER 2>/dev/null || true
sudo ip link set tap2 master br0
sudo ip link set tap2 up

echo "[SUCCESS] Bridge and TAP interfaces ready"