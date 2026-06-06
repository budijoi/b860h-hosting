#!/bin/bash

clear

CONFIG_FILE="/etc/budijoi-server.conf"

echo "========================================="
echo "[2/10] STORAGE DETECTION"
echo "========================================="
echo ""

ROOT_SOURCE=$(findmnt -n -o SOURCE /)
ROOT_DISK=$(lsblk -no PKNAME "$ROOT_SOURCE" 2>/dev/null)

echo "Root Filesystem : $ROOT_SOURCE"
echo ""

echo "Storage yang terdeteksi:"
echo ""

INDEX=1

declare -A DEVICES

while read -r NAME FSTYPE SIZE LABEL
do

```
DEVICE="/dev/$NAME"

DEV_PARENT=$(lsblk -no PKNAME "$DEVICE" 2>/dev/null)

if [ "$DEV_PARENT" = "$ROOT_DISK" ]; then
    continue
fi

DEVICES[$INDEX]="$DEVICE"

echo "[$INDEX] $DEVICE"
echo "    Filesystem : ${FSTYPE:-unknown}"
echo "    Size       : $SIZE"
echo "    Label      : ${LABEL:-none}"
echo ""

INDEX=$((INDEX+1))
```

done < <(
lsblk -lnpo NAME,FSTYPE,SIZE,LABEL |
awk '$1 ~ /[0-9]$/'
)

if [ ${#DEVICES[@]} -eq 0 ]; then

```
echo "Tidak ada storage tambahan ditemukan."
echo ""

read -p "Tekan ENTER untuk melanjutkan..."
exit 0
```

fi

read -p "Pilih storage yang akan digunakan: " CHOICE

STORAGE_DEVICE="${DEVICES[$CHOICE]}"

if [ -z "$STORAGE_DEVICE" ]; then

```
echo ""
echo "[ERROR] Pilihan tidak valid."
exit 1
```

fi

FSTYPE=$(blkid -o value -s TYPE "$STORAGE_DEVICE")
UUID=$(blkid -o value -s UUID "$STORAGE_DEVICE")

echo ""
echo "Storage dipilih:"
echo "$STORAGE_DEVICE"
echo ""

echo "Filesystem:"
echo "$FSTYPE"
echo ""

if [ "$FSTYPE" != "ext4" ]; then

```
echo "Rekomendasi:"
echo "ext4 untuk Home Server"
echo ""

echo "1. Gunakan filesystem saat ini"
echo "2. Format ke ext4"
echo "3. Batal"
echo ""

read -p "Pilihan [1-3]: " FS_OPTION

case $FS_OPTION in

    1)
        ;;
    2)

        echo ""
        echo "PERINGATAN!"
        echo "Semua data pada $STORAGE_DEVICE akan dihapus."
        echo ""

        read -p "Ketik FORMAT untuk melanjutkan: " CONFIRM

        if [ "$CONFIRM" != "FORMAT" ]; then
            echo "Dibatalkan."
            exit 0
        fi

        mkfs.ext4 -F "$STORAGE_DEVICE"

        FSTYPE="ext4"

        UUID=$(blkid -o value -s UUID "$STORAGE_DEVICE")
        ;;

    *)
        echo "Dibatalkan."
        exit 0
        ;;

esac
```

fi

mkdir -p /mnt/storage

case "$FSTYPE" in

```
ext4)

    FSTAB_ENTRY="UUID=$UUID /mnt/storage ext4 defaults,nofail 0 2"
    ;;

exfat)

    apt install -y exfat-fuse exfatprogs >/dev/null 2>&1

    FSTAB_ENTRY="UUID=$UUID /mnt/storage exfat defaults,nofail,uid=1000,gid=1000 0 0"
    ;;

vfat)

    FSTAB_ENTRY="UUID=$UUID /mnt/storage vfat defaults,nofail,uid=1000,gid=1000 0 0"
    ;;

ntfs)

    apt install -y ntfs-3g >/dev/null 2>&1

    FSTAB_ENTRY="UUID=$UUID /mnt/storage ntfs defaults,nofail 0 0"
    ;;

*)

    echo ""
    echo "[ERROR] Filesystem tidak didukung:"
    echo "$FSTYPE"
    exit 1
    ;;
```

esac

sed -i '//mnt/storage/d' /etc/fstab

echo "$FSTAB_ENTRY" >> /etc/fstab

systemctl daemon-reload

mount /mnt/storage 2>/dev/null || mount -a

if mountpoint -q /mnt/storage
then

```
echo ""
echo "[✓] Storage berhasil di-mount"
echo ""

mkdir -p /mnt/storage/{public,private,backup,web,share}

mkdir -p /etc

touch "$CONFIG_FILE"

grep -q "^STORAGE_PATH=" "$CONFIG_FILE" 2>/dev/null \
    && sed -i 's|^STORAGE_PATH=.*|STORAGE_PATH=/mnt/storage|' "$CONFIG_FILE" \
    || echo "STORAGE_PATH=/mnt/storage" >> "$CONFIG_FILE"
```

else

```
echo ""
echo "[✗] Gagal mount storage"
exit 1
```

fi

echo ""
echo "========================================="
echo " STORAGE CONFIGURATION COMPLETE"
echo "========================================="
echo ""

df -h /mnt/storage

echo ""

read -p "Tekan ENTER untuk melanjutkan..."
