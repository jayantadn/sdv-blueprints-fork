#!/bin/bash

set -e

echo "[INFO] Updating system..."
sudo apt update

echo "[INFO] Installing dependencies..."

sudo apt install -y \
    qemu-system-x86 \
    qemu-kvm \
    cloud-image-utils \
    python3-pip

echo "[INFO] Installing Python packages..."
pip3 install requests tqdm

echo "[SUCCESS] Setup complete!"
