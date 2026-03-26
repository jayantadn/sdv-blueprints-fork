#!/bin/bash

set -e

echo "[INFO] Creating seed.img..."

cloud-localds seed.img cloud-init/user-data cloud-init/meta-data

echo "[SUCCESS] seed.img created"