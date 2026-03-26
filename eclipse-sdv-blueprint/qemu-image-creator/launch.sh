#!/bin/sh

set -e

IMAGE="images/noble-server-cloudimg-amd64.img"

# Auto-download if not present
if [ ! -f "$IMAGE" ]; then
  echo "[INFO] Image not found. Downloading..."
  python3 create_image.py
fi

# Create seed image
./create_seed_img.sh

echo "[INFO] Launching QEMU..."

qemu-system-x86_64 \
  -enable-kvm \
  -m 2048 \
  -cpu host \
  -drive file=$IMAGE,format=qcow2,if=virtio \
  -cdrom seed.img \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net0 \
  -nographic
  