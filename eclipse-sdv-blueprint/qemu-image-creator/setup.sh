#!/bin/bash

set -e

echo "======================================"
echo "[INFO] FULL SETUP SCRIPT STARTED"
echo "======================================"

echo "======================================"
echo "[INFO] ROOT PRIVILEGES REQUIRED"
echo "======================================"

# -------- CONFIG --------
BASE_URL="https://cloud-images.ubuntu.com/noble/current/"
IMAGE_NAME="noble-server-cloudimg-amd64.img"
DOWNLOAD_DIR="images"
BASE_IMAGE="$DOWNLOAD_DIR/$IMAGE_NAME"
FINAL_IMAGE="ubuntu-final.qcow2"
SEED_IMAGE="seed.img"

# -------- SYSTEM UPDATE --------
echo "[INFO] Updating system..."
sudo apt update && sudo apt upgrade -y

# -------- INSTALL DEPENDENCIES --------
echo "[INFO] Installing required packages..."

sudo apt install -y \
    qemu-system \
    qemu-utils \
    cloud-image-utils \
    wget

# -------- KVM SETUP --------
echo "[INFO] Checking KVM..."

if [ -e /dev/kvm ]; then
    echo "[INFO] /dev/kvm exists"

    if groups | grep -q '\bkvm\b'; then
        echo "[SUCCESS] KVM accessible ✅"
    else
        echo "[INFO] Adding user to kvm group..."
        sudo usermod -aG kvm $USER
        echo "[WARNING] Restart WSL required"
    fi
else
    echo "[WARNING] KVM not available (will run slower)"
fi

# -------- CREATE IMAGE DIRECTORY --------
mkdir -p $DOWNLOAD_DIR

# -------- DOWNLOAD IMAGE (PYTHON REPLACEMENT) --------
echo "[INFO] Downloading Ubuntu cloud image..."

if [ -f "$BASE_IMAGE" ]; then
    echo "[INFO] Image already exists: $BASE_IMAGE"
else
    wget -O $BASE_IMAGE "$BASE_URL/$IMAGE_NAME"
    echo "[SUCCESS] Downloaded image"
fi

# -------- CREATE QCOW2 IMAGE --------
echo "[INFO] Creating QCOW2 disk..."

if [ -f "$FINAL_IMAGE" ]; then
    echo "[INFO] Final image already exists"
else
    qemu-img create -f qcow2 -F qcow2 -b $BASE_IMAGE $FINAL_IMAGE 50G
    echo "[SUCCESS] QCOW2 image created"
fi

# -------- CREATE CLOUD-INIT FILES --------
echo "[INFO] Creating cloud-init config..."

mkdir -p init

cat > init/user-data <<EOF
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    home: /home/ubuntu
    shell: /bin/bash

chpasswd:
  list: |
    ubuntu:ubuntu
  expire: false

ssh_pwauth: true
EOF

cat > init/meta-data <<EOF
instance-id: iid-local01
local-hostname: ubuntu-vm
EOF

# -------- CREATE SEED IMAGE --------
echo "[INFO] Creating seed.img..."

cloud-localds $SEED_IMAGE init/user-data init/meta-data

echo "[SUCCESS] seed.img created"

echo ""
echo "======================================"
echo "[SUCCESS] SETUP COMPLETED ✅"
echo "======================================"
echo ""
echo "Next step:"
echo "Run: ./launch.sh"