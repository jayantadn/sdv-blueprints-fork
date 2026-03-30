# QEMU Ubuntu VM Image Creator (Single VM)

This project provides a simple and automated way to create and launch a single Ubuntu VM using QEMU with with internet.

It uses:
- Ubuntu Cloud Image
- QEMU virtualization
- Cloud-init for configuration

---

## 📁 Project Structure
```
.
├── setup.sh # One-time setup (downloads image, creates disk, prepares VM)
├── launch.sh # Launches the VM
├── input/ # User-provided configuration (static)
│ ├── user-data # Cloud-init configuration
│ └── meta-data
├── output/ # Generated files (created after setup)
│ ├── images/ # Ubuntu cloud image
│ ├── ubuntu-final.qcow2
│ └── seed.img
```

---

## 🚀 Quick Start

### 1. Make scripts executable

```bash
chmod +x *.sh
```

---

### 2. Run Setup (One-time)

```bash
./setup.sh
```

This will:
- Install required dependencies
- Download Ubuntu cloud image
- Create QCOW2 disk
- Generate seed.img using cloud-init

---

### 3. Launch VM

```bash
./launch.sh
```
✅ After setup, you only need to run launch.sh every time.

---

## 🔐 Login Details

```
Username: ubuntu
Password: ubuntu
```

---

## 🌐 SSH Access

After VM boots, open a new terminal and run:
```
ssh ubuntu@localhost -p 2222
```
---

## 🔁 Reset VM (if needed)

If you modify input/user-data or want a fresh setup:
```
rm -rf output/
./setup.sh
```

---
