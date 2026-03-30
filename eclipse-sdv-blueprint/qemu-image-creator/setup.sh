#!/bin/bash

set -e

echo "======================================"
echo "[INFO] FULL SETUP SCRIPT STARTED"
echo "======================================"

echo "======================================"
echo "ROOT PRIVILEGES REQUIRED"
echo "======================================"

# -------- CONFIG --------
BASE_URL="https://cloud-images.ubuntu.com/noble/current/"
IMAGE_NAME="noble-server-cloudimg-amd64.img"

INPUT_DIR="input"
OUTPUT_DIR="output"

IMAGE_DIR="$OUTPUT_DIR/images"
BASE_IMAGE="$IMAGE_DIR/$IMAGE_NAME"
FINAL_IMAGE="$OUTPUT_DIR/ubuntu-final.qcow2"
SEED_IMAGE="$OUTPUT_DIR/seed.img"

USER_DATA="$INPUT_DIR/user-data"
META_DATA="$INPUT_DIR/meta-data"

# -------- VALIDATE INPUT --------
if [ ! -f "$USER_DATA" ] || [ ! -f "$META_DATA" ]; then
    echo "[ERROR] user-data or meta-data not found in input/ folder"
    exit 1
fi

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

# -------- KVM CHECK --------
echo "[INFO] Checking KVM..."

if [ -e /dev/kvm ]; then
    if groups | grep -q '\bkvm\b'; then
        echo "[SUCCESS] KVM accessible ✅"
    else
        sudo usermod -aG kvm $USER
        echo "[WARNING] Restart required for KVM access"
    fi
else
    echo "[WARNING] KVM not available (will run slower)"
fi

# -------- CREATE OUTPUT DIRECTORIES --------
mkdir -p "$IMAGE_DIR"

# -------- DOWNLOAD IMAGE --------
echo "[INFO] Downloading Ubuntu cloud image..."

if [ -f "$BASE_IMAGE" ]; then
    echo "[INFO] Image already exists"
else
    wget -O "$BASE_IMAGE" "$BASE_URL/$IMAGE_NAME"
    echo "[SUCCESS] Downloaded image"
fi

# -------- CREATE QCOW2 --------
echo "[INFO] Creating QCOW2 disk..."

if [ -f "$FINAL_IMAGE" ]; then
    echo "[INFO] QCOW2 already exists"
else
    qemu-img create -f qcow2 -F qcow2 -b "images/$IMAGE_NAME" "$FINAL_IMAGE" 50G
    echo "[SUCCESS] QCOW2 created"
fi

# -------- CREATE SEED IMAGE --------
echo "[INFO] Creating seed.img..."

cloud-localds "$SEED_IMAGE" "$USER_DATA" "$META_DATA"

echo "[SUCCESS] seed.img created"

echo ""
echo "======================================"
echo "[SUCCESS] SETUP COMPLETED ✅"
echo "======================================"
echo ""
echo "Run: ./launch.sh"