#!/bin/bash

# =====================================================

# B860H HOSTING EDITION V4 FINAL

# Armbian + Nginx + PHP + MariaDB + FileBrowser

# Storage SD Card + Swap SD Card + Auto Backup

# =====================================================

set -e

clear

echo "====================================================="
echo "         B860H HOSTING EDITION V4 FINAL"
echo "====================================================="
echo ""
echo "Komponen yang akan diinstall:"
echo " - Nginx"
echo " - PHP-FPM"
echo " - MariaDB"
echo " - FileBrowser"
echo " - UFW Firewall"
echo " - Fail2Ban"
echo " - Auto Backup"
echo " - Swap di SD Card"
echo ""

if [ "$EUID" -ne 0 ]; then
echo "ERROR: Jalankan sebagai root"
exit 1
fi

echo "====================================================="
echo " INFORMASI SISTEM"
echo "====================================================="

hostnamectl | grep "Operating System" || true

echo ""
echo "Storage:"
lsblk

echo ""

echo "====================================================="
echo " [1/12] UPDATE SISTEM"
echo "====================================================="

apt update
apt upgrade -y

echo ""
echo "====================================================="
echo " [2/12] INSTALL PAKET DASAR"
echo "====================================================="

apt install -y 
curl 
wget 
nano 
git 
unzip 
htop 
sudo 
ca-certificates 
ufw 
fail2ban

echo ""
echo "====================================================="
echo " [3/12] DETEKSI STORAGE"
echo "====================================================="

ROOT_DEVICE=$(findmnt -n -o SOURCE /)

echo "Root filesystem:"
echo "$ROOT_DEVICE"

SD_PART=$(lsblk -lnpo NAME,FSTYPE | 
awk '$2=="ext4"{print $1}' | 
grep -v "$ROOT_DEVICE" | 
head -n1)

if [ -z "$SD_PART" ]; then
echo ""
echo "ERROR:"
echo "Partisi SD Card ext4 tidak ditemukan."
echo ""
echo "Format SD Card ke ext4 terlebih dahulu."
exit 1
fi

echo ""
echo "Storage SD Card:"
echo "$SD_PART"

UUID=$(blkid -s UUID -o value "$SD_PART")

mkdir -p /mnt/storage

if ! grep -q "$UUID" /etc/fstab; then
echo "UUID=$UUID /mnt/storage ext4 defaults,nofail 0 2" >> /etc/fstab
fi

systemctl daemon-reload
mount -a

echo ""
echo "====================================================="
echo " [4/12] MEMBUAT STRUKTUR STORAGE"
echo "====================================================="

mkdir -p /mnt/storage/files
mkdir -p /mnt/storage/media
mkdir -p /mnt/storage/backup
mkdir -p /mnt/storage/website-data
mkdir -p /mnt/storage/logs
mkdir -p /mnt/storage/filebrowser

echo "OK"

echo ""
echo "====================================================="
echo " [5/12] MEMBUAT SWAP DI SD CARD"
echo "====================================================="

if [ ! -f /mnt/storage/swapfile ]; then

```
fallocate -l 1G /mnt/storage/swapfile

chmod 600 /mnt/storage/swapfile

mkswap /mnt/storage/swapfile
```

fi

if ! grep -q "/mnt/storage/swapfile" /etc/fstab; then
echo "/mnt/storage/swapfile none swap sw 0 0" >> /etc/fstab
fi

swapon -a || true

echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf

sysctl -p /etc/sysctl.d/99-swappiness.conf

echo "Swap aktif"

echo ""
echo "====================================================="
echo " [6/12] INSTALL NGINX"
echo "====================================================="

apt install -y nginx

systemctl enable nginx
systemctl restart nginx

echo "Nginx OK"

echo ""
echo "====================================================="
echo " [7/12] INSTALL PHP"
echo "====================================================="

apt install -y 
php-fpm 
php-cli 
php-common 
php-curl 
php-mysql 
php-gd 
php-mbstring 
php-xml 
php-zip

echo "PHP OK"

echo ""
echo "====================================================="
echo " [8/12] INSTALL MARIADB"
echo "====================================================="

apt install -y mariadb-server mariadb-client

systemctl enable mariadb
systemctl start mariadb

echo "MariaDB OK"

echo ""
echo "====================================================="
echo " [9/12] MEMBUAT WEBSITE DEFAULT"
echo "====================================================="

cat > /var/www/html/index.php << 'EOF'

<?php
echo "<h1>B860H Hosting Server</h1>";
echo "<p>Powered by Armbian</p>";
?>

EOF

chown -R www-data:www-data /var/www/html

echo "Website default dibuat"

echo ""
echo "====================================================="
echo " [10/12] INSTALL FILEBROWSER"
echo "====================================================="

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

if [ ! -f /mnt/storage/filebrowser/filebrowser.db ]; then

```
filebrowser config init \
-d /mnt/storage/filebrowser/filebrowser.db

filebrowser users add admin admin12345678 \
--perm.admin \
-d /mnt/storage/filebrowser/filebrowser.db
```

fi

cat > /etc/systemd/system/filebrowser.service << 'EOF'
[Unit]
Description=FileBrowser
After=network.target

[Service]
Type=simple
User=root

ExecStart=/usr/local/bin/filebrowser 
-r /mnt/storage/files 
-d /mnt/storage/filebrowser/filebrowser.db 
-a 0.0.0.0 
-p 8080

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable filebrowser
systemctl restart filebrowser

echo "FileBrowser OK"

echo ""
echo "====================================================="
echo " [11/12] FIREWALL & FAIL2BAN"
echo "====================================================="

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp

ufw --force enable

systemctl enable fail2ban
systemctl restart fail2ban

echo "Security OK"

echo ""
echo "====================================================="
echo " [12/12] AUTO BACKUP"
echo "====================================================="

cat > /usr/local/bin/backup-web.sh << 'EOF'
#!/bin/bash

DATE=$(date +%F_%H-%M)

tar -czf 
/mnt/storage/backup/web-$DATE.tar.gz 
/var/www/html
EOF

chmod +x /usr/local/bin/backup-web.sh

cat > /usr/local/bin/backup-mariadb.sh << 'EOF'
#!/bin/bash

DATE=$(date +%F_%H-%M)

mysqldump --all-databases \

> /mnt/storage/backup/mysql-$DATE.sql
> EOF

chmod +x /usr/local/bin/backup-mariadb.sh

(crontab -l 2>/dev/null | grep -v backup-web.sh; 
echo "0 2 * * * /usr/local/bin/backup-web.sh") | crontab -

(crontab -l 2>/dev/null | grep -v backup-mariadb.sh; 
echo "30 2 * * * /usr/local/bin/backup-mariadb.sh") | crontab -

echo "Backup OK"

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "====================================================="
echo " INSTALASI SELESAI"
echo "====================================================="
echo ""
echo "Website:"
echo "http://$IP"
echo ""
echo "FileBrowser:"
echo "http://$IP:8080"
echo ""
echo "Login FileBrowser:"
echo "user : admin"
echo "pass : admin12345678"
echo ""
echo "Storage:"
echo "/mnt/storage"
echo ""
echo "Website:"
echo "/var/www/html"
echo ""
echo "Backup:"
echo "/mnt/storage/backup"
echo ""
echo "====================================================="
echo " LANGKAH SELANJUTNYA"
echo "====================================================="
echo ""
echo "1. Install Cloudflared:"
echo ""
echo "wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
echo "chmod +x cloudflared-linux-arm64"
echo "mv cloudflared-linux-arm64 /usr/local/bin/cloudflared"
echo ""
echo "2. Login Cloudflare:"
echo ""
echo "cloudflared tunnel login"
echo ""
echo "3. Edit Website:"
echo ""
echo "nano /var/www/html/index.php"
echo ""
echo "atau"
echo ""
echo "nano /var/www/html/index.html"
echo ""
echo "4. Cek Service:"
echo ""
echo "systemctl status nginx"
echo "systemctl status mariadb"
echo "systemctl status filebrowser"
echo ""
echo "====================================================="
