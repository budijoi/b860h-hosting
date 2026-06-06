#!/bin/bash

clear

echo "========================================="
echo "[2/10] STORAGE DETECTION"
echo "========================================="
echo ""

ROOTFS=$(findmnt -n -o SOURCE /)

ROOT_DISK=$(lsblk -no PKNAME "$ROOTFS" 2>/dev/null)

STORAGE_DEVICE=""

for DEV in $(lsblk -ln -o NAME,TYPE | awk '$2=="part"{print $1}')
do
    if [[ "$DEV" != *"$ROOT_DISK"* ]]; then
        STORAGE_DEVICE="/dev/$DEV"
        break
    fi
done

echo "Root Filesystem : $ROOTFS"

if [ -n "$STORAGE_DEVICE" ]; then
    echo "Storage Device  : $STORAGE_DEVICE"
else
    echo "Storage Device  : Tidak ditemukan"
fi

echo ""
echo "Mount Point yang akan digunakan:"
echo "/mnt/storage"
echo ""

read -p "Lanjutkan konfigurasi storage? [Y/N] : " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Storage dilewati."
    exit 0
fi

mkdir -p /mnt/storage

if [ -n "$STORAGE_DEVICE" ]; then

    UUID=$(blkid -s UUID -o value "$STORAGE_DEVICE")

    if ! grep -q "$UUID" /etc/fstab; then

        echo ""
        echo "[INFO] Menambahkan ke fstab..."

        echo "UUID=$UUID /mnt/storage ext4 defaults,nofail 0 2" >> /etc/fstab

    fi

    mount -a

    echo ""
    echo "[OK] Storage berhasil dikonfigurasi."

else

    echo ""
    echo "[WARNING] Tidak ada storage tambahan ditemukan."

fi

echo ""
echo "========================================="
echo " STORAGE CONFIGURATION COMPLETE"
echo "========================================="
echo ""

read -p "Tekan ENTER untuk melanjutkan..."