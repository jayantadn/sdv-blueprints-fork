# QEMU Ubuntu VM Image Creator

This project provides a simple and automated way to create and launch an Ubuntu VM using QEMU with cloud-init.

It uses:
- Ubuntu Cloud Image
- QEMU virtualization
- Cloud-init for configuration

---

## 📁 Project Structure
```
.
├── setup.sh # One-time setup (downloads image, creates disk, configures cloud-init)
├── launch.sh # Launches the VM
├── images/ # Stores downloaded Ubuntu cloud image
├── init/ # Cloud-init configuration files 
├── ubuntu-final.qcow2 # Generated VM disk 
├── seed.img # Cloud-init seed image

Note:  
The files `images/`, `init/`, `ubuntu-final.qcow2`, and `seed.img` are generated only after running `setup.sh`.
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
- Generate cloud-init config
- Create `seed.img`

---

### 3. Launch VM

```bash
./launch.sh
```

---

## 🔐 Login Details

```
Username: ubuntu
Password: ubuntu
```

---

## ▶️ Launching VM (Every Time)

After setup is completed, you only need to run:
```
./launch.sh

```
Note:
You do NOT need to run setup.sh again unless:
- You want to reset the VM
- You changed cloud-init configuration files
- You deleted generated files

---
