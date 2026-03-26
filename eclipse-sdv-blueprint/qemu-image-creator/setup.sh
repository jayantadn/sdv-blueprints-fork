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
echo "⚠️ IMPORTANT: KVM group added."
echo "If this is your first time, restart WSL after setup:"
echo "1. Exit terminal"
echo "2. Run: wsl --shutdown (in Windows PowerShell)"
echo "3. Reopen WSL"
echo ""

echo "[INFO] Checking /dev/kvm..."

if [ -e /dev/kvm ]; then
    echo "[SUCCESS] /dev/kvm exists"
    ls -l /dev/kvm
else
    echo "[WARNING] /dev/kvm not found"
fi

echo "[INFO] Checking user groups..."
groups

echo "[INFO] Testing KVM support (silent check)..."

if timeout 2 qemu-system-x86_64 -enable-kvm -cpu host -m 512 \
    -nographic -display none -serial none 2>/dev/null; then
    echo "[SUCCESS] KVM is working ✅"
else
    echo "[WARNING] KVM not accessible ⚠️"
    echo "QEMU will run in software mode (slower)"
fi

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
echo "2. Run: ./launch.sh"
