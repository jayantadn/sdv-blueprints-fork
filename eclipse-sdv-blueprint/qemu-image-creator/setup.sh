#!/bin/bash

set -e

echo "[INFO] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[INFO] Installing QEMU and required dependencies..."

sudo apt install -y \
    qemu-system \
    cloud-image-utils \
    python3-pip

echo "[INFO] Installing Python dependencies..."

pip3 install requests tqdm --break-system-packages

echo "[INFO] Adding user to kvm group..."

sudo usermod -aG kvm $USER

echo ""
echo "⚠️ IMPORTANT: If this is your first time, restart WSL after setup:"
echo "1. Exit terminal"
echo "2. Run: wsl --shutdown (in Windows PowerShell)"
echo "3. Reopen WSL"
echo ""

# -------- KVM CHECK (CLEAN VERSION) --------

echo "[INFO] Checking KVM availability..."

if [ -e /dev/kvm ]; then
    echo "[INFO] /dev/kvm exists"

    if groups | grep -q '\bkvm\b'; then
        echo "[SUCCESS] KVM is available and accessible ✅"
    else
        echo "[WARNING] KVM device exists but user is not in 'kvm' group ⚠️"
        echo "Run: sudo usermod -aG kvm \$USER and restart WSL"
    fi

else
    echo "[WARNING] /dev/kvm not found ⚠️"
    echo "KVM not available. QEMU will run in software mode."
fi

# -------- PATH FIX --------

echo "[INFO] Fixing PATH for Python user packages..."

if ! grep -q 'export PATH=$HOME/.local/bin:$PATH' ~/.bashrc; then
    echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
    echo "[INFO] Added ~/.local/bin to PATH"
fi

echo ""
echo "[SUCCESS] Setup complete!"
echo ""

echo "Next steps:"
echo "1. Restart terminal OR run: source ~/.bashrc"
echo "2. Run: python3 create_image.py to create the base image (only needed once)"
echo "3. Run: ./launch.sh"