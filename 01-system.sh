#!/bin/bash

clear

echo "========================================="
echo "[1/10] SYSTEM PREPARATION"
echo "========================================="
echo ""

echo "Script akan:"
echo "✓ Update repository"
echo "✓ Upgrade package"
echo "✓ Install dependency dasar"
echo ""

read -p "Lanjutkan? [Y/N] : " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Dibatalkan."
    exit 0
fi

echo ""
echo "[INFO] Updating repository..."
apt update

echo ""
echo "[INFO] Upgrading packages..."
apt upgrade -y

echo ""
echo "[INFO] Installing dependencies..."

apt install -y \
curl \
wget \
unzip \
zip \
git \
nano \
htop \
net-tools \
sudo \
ca-certificates \
software-properties-common \
apt-transport-https \
lsb-release

echo ""
echo "========================================="
echo " SYSTEM PREPARATION COMPLETE"
echo "========================================="
echo ""

read -p "Tekan ENTER untuk melanjutkan..."