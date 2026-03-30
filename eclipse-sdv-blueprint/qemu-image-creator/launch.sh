#!/bin/bash

set -e

OUTPUT_DIR="output"

FINAL_IMAGE="$OUTPUT_DIR/ubuntu-final.qcow2"
SEED_IMAGE="$OUTPUT_DIR/seed.img"

echo "======================================"
echo "[INFO] VM LAUNCH SCRIPT"
echo "======================================"

# -------- CHECK FILES --------
if [ ! -f "$FINAL_IMAGE" ] || [ ! -f "$SEED_IMAGE" ]; then
    echo "[ERROR] Required files not found in output/"
    echo "👉 Run: ./setup.sh first"
    exit 1
fi

# -------- KVM + CPU --------
if [ -e /dev/kvm ] && groups | grep -q '\bkvm\b'; then
    KVM_FLAG="-enable-kvm"
    CPU_FLAG="-cpu host"
else
    KVM_FLAG=""
    CPU_FLAG="-cpu qemu64"
fi

# -------- RUN VM --------
qemu-system-x86_64 \
    $KVM_FLAG \
    $CPU_FLAG \
    -m 2048 \
    -smp 2 \
    -drive file=$FINAL_IMAGE,format=qcow2,if=virtio \
    -drive file=$SEED_IMAGE,format=raw,if=virtio \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 \
    -bios /usr/share/qemu/OVMF.fd \
    -nographic