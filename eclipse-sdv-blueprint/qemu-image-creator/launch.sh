#!/bin/sh

set -e

IMAGE="images/noble-server-cloudimg-amd64.img"

# Check image
if [ ! -f "$IMAGE" ]; then
  echo "[ERROR] Image not found. Run create_image.py first."
  exit 1
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