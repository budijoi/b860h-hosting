#!/bin/bash

# ==================================================
# BUDIJOI SERVER INSTALLER
# Version : 1.0
# ==================================================

clear

INSTALL_INFO="/root/budijoi-server-info.txt"

echo "========================================="
echo "      B860H HOMESERVER INSTALLER"
echo "========================================="
echo ""

# Root check
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Jalankan sebagai root!"
    exit 1
fi

# Detect system information

HOSTNAME=$(hostname)
KERNEL=$(uname -r)
IP=$(hostname -I | awk '{print $1}')
CPU=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d ":" -f2 | xargs)

MEMORY=$(free -h | awk '/Mem:/ {print $2}')

echo "Hostname : $HOSTNAME"
echo "Kernel   : $KERNEL"
echo "IP       : $IP"
echo "RAM      : $MEMORY"
echo ""

echo "========================================="
echo " Tahapan Instalasi"
echo "========================================="
echo "1. System Preparation"
echo "2. Storage Detection"
echo "3. Swap Configuration"
echo "4. Install NGINX"
echo "5. Install PHP-FPM"
echo "6. Install MariaDB"
echo "7. Install File Browser"
echo "8. Configure Firewall"
echo "9. Generate Web Pages"
echo "10. Finish"
echo ""

read -p "Tekan ENTER untuk memulai..."

mkdir -p modules

echo "========================================="
echo "Memulai Instalasi..."
echo "========================================="

# Jalankan Module

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

bash "$SCRIPT_DIR/modules/01-system.sh"
bash "$SCRIPT_DIR/modules/02-storage.sh"

echo ""
echo "Tahap berikutnya akan dibuat pada modul selanjutnya."
echo ""
