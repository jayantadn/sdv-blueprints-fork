#!/bin/bash
set -e

echo "======================================"
echo "[INFO] MULTI-VM SETUP STARTED"
echo "======================================"

# -------- CONFIG --------
BASE_URL="https://cloud-images.ubuntu.com/noble/current/"
IMAGE_NAME="noble-server-cloudimg-amd64.img"

INPUT_DIR="input"
OUTPUT_DIR="output"
IMAGE_DIR="$OUTPUT_DIR/images"

VM1_IMG="$OUTPUT_DIR/vm1.qcow2"
VM2_IMG="$OUTPUT_DIR/vm2.qcow2"

SEED1="$OUTPUT_DIR/seed1.img"
SEED2="$OUTPUT_DIR/seed2.img"

# -------- CHECK INPUT FILES --------
if [ ! -f "$INPUT_DIR/user-data-vm1" ] || [ ! -f "$INPUT_DIR/meta-data-vm1" ]; then
    echo "[ERROR] VM1 cloud-init files missing"
    exit 1
fi

if [ ! -f "$INPUT_DIR/user-data-vm2" ] || [ ! -f "$INPUT_DIR/meta-data-vm2" ]; then
    echo "[ERROR] VM2 cloud-init files missing"
    exit 1
fi

# -------- INSTALL DEPENDENCIES --------
echo "[INFO] Installing dependencies..."
sudo apt update
sudo apt install -y qemu-system qemu-utils cloud-image-utils wget bridge-utils

# -------- KVM CHECK --------
echo "[INFO] Checking KVM..."
if [ -e /dev/kvm ] && groups | grep -q '\bkvm\b'; then
    echo "[SUCCESS] KVM enabled"
else
    echo "[WARNING] KVM not enabled (slower VM)"
fi

# -------- CREATE DIRS --------
mkdir -p "$IMAGE_DIR"

BASE_IMAGE="$IMAGE_DIR/$IMAGE_NAME"

# -------- DOWNLOAD BASE IMAGE --------
if [ ! -f "$BASE_IMAGE" ]; then
    echo "[INFO] Downloading Ubuntu image..."
    wget -O "$BASE_IMAGE" "$BASE_URL/$IMAGE_NAME"
else
    echo "[INFO] Base image already exists"
fi

# -------- CREATE VM DISKS --------
if [ ! -f "$VM1_IMG" ]; then
    echo "[INFO] Creating VM1 disk..."
    qemu-img create -f qcow2 -F qcow2 -b "images/$IMAGE_NAME" "$VM1_IMG" 30G
fi

if [ ! -f "$VM2_IMG" ]; then
    echo "[INFO] Creating VM2 disk..."
    qemu-img create -f qcow2 -F qcow2 -b "images/$IMAGE_NAME" "$VM2_IMG" 30G
fi

# -------- CREATE SEED IMAGES --------
echo "[INFO] Creating cloud-init seeds..."
cloud-localds --network-config "$INPUT_DIR/network-vm1.yaml" "$SEED1" "$INPUT_DIR/user-data-vm1" "$INPUT_DIR/meta-data-vm1"
cloud-localds --network-config "$INPUT_DIR/network-vm2.yaml" "$SEED2" "$INPUT_DIR/user-data-vm2" "$INPUT_DIR/meta-data-vm2"

echo "======================================"
echo "[SUCCESS] SETUP COMPLETED"
echo "======================================"
echo "Next: run ./network.sh"