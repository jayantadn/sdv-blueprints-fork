#!/bin/bash
 
set -e
 
FINAL_IMAGE="ubuntu-final.qcow2"
SEED_IMAGE="seed.img"
 
echo "======================================"
echo "[INFO] VM LAUNCH SCRIPT"
echo "======================================"
 
# -------- CHECK FILES --------
if [ ! -f "$FINAL_IMAGE" ]; then
    echo "[ERROR] $FINAL_IMAGE not found"
    echo "Run: ./setup.sh first"
    exit 1
fi
 
if [ ! -f "$SEED_IMAGE" ]; then
    echo "[ERROR] $SEED_IMAGE not found"
    echo "Run: ./setup.sh first"
    exit 1
fi
 
# -------- KVM + CPU CHECK --------
echo "[INFO] Checking KVM..."
 
if [ -e /dev/kvm ] && groups | grep -q '\bkvm\b'; then
    echo "[INFO] KVM enabled ✅"
    KVM_FLAG="-enable-kvm"
    CPU_FLAG="-cpu host"
else
    echo "[WARNING] Running without KVM (slower)"
    KVM_FLAG=""
    CPU_FLAG="-cpu qemu64"
fi
 
# -------- LAUNCH VM --------
echo "[INFO] Starting QEMU VM..."
 
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
 
echo "[INFO] VM stopped"