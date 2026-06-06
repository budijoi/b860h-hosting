#!/bin/bash

clear

echo "========================================="
echo "[3/10] SWAP CONFIGURATION"
echo "========================================="
echo ""

echo "Pilih ukuran swap"
echo ""
echo "1. 512 MB"
echo "2. 1 GB"
echo "3. 2 GB"
echo "4. Skip"
echo ""

read -p "Pilihan [1-4] : " SWAP_CHOICE

case $SWAP_CHOICE in
    1) SWAP_SIZE="512M" ;;
    2) SWAP_SIZE="1G" ;;
    3) SWAP_SIZE="2G" ;;
    4)
        echo "Swap dilewati."
        read -p "ENTER..."
        exit 0
        ;;
    *)
        echo "Pilihan tidak valid."
        exit 1
        ;;
esac

echo ""
echo "Swap akan dibuat sebesar $SWAP_SIZE"
echo ""

read -p "Lanjutkan? [Y/N] : " CONFIRM

[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && exit 0

swapoff /swapfile 2>/dev/null
rm -f /swapfile

fallocate -l "$SWAP_SIZE" /swapfile

chmod 600 /swapfile

mkswap /swapfile

swapon /swapfile

grep -q "/swapfile" /etc/fstab || \
echo "/swapfile none swap sw 0 0" >> /etc/fstab

echo ""
echo "[✓] Swap berhasil dibuat"
echo ""

read -p "Tekan ENTER..."