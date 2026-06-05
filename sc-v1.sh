#!/bin/bash

set -e

clear

echo "==========================================="
echo " B860H HOSTING EDITION V1 By Budijoi"
echo "==========================================="

if [ "$EUID" -ne 0 ]; then
    echo "Jalankan sebagai root"
    exit 1
fi

#########################################
# UPDATE
#########################################

echo "[1/13] Update system..."

apt update
apt upgrade -y

#########################################
# BASIC TOOLS
#########################################

echo "[2/13] Install basic packages..."

apt install -y \
curl \
wget \
nano \
git \
unzip \
htop \
sudo \
ufw \
fail2ban \
ca-certificates

#########################################
# DETEKSI SD CARD
#########################################

echo "[3/13] Detecting SD Card..."

mkdir -p /mnt/storage

ROOT_DEV=$(findmnt -n -o SOURCE /)

SD_DEV=$(lsblk -lnpo NAME,TYPE | \
awk '$2=="part"{print $1}' | \
grep mmcblk | \
grep -v "$ROOT_DEV" | \
head -n1)

if [ -z "$SD_DEV" ]; then
    echo ""
    echo "ERROR: SD Card tidak ditemukan."
    echo ""
    exit 1
fi

UUID=$(blkid -s UUID -o value "$SD_DEV")

if [ -z "$UUID" ]; then
    echo ""
    echo "ERROR: Partisi SD Card belum diformat."
    echo "Format ke ext4 terlebih dahulu."
    echo ""
    exit 1
fi

#########################################
# MOUNT STORAGE
#########################################

echo "[4/13] Mounting storage..."

if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=$UUID /mnt/storage ext4 defaults,nofail 0 2" >> /etc/fstab
fi

mount -a

#########################################
# STORAGE STRUCTURE
#########################################

echo "[5/13] Creating storage folders..."

mkdir -p /mnt/storage/files
mkdir -p /mnt/storage/media
mkdir -p /mnt/storage/backup
mkdir -p /mnt/storage/website-data
mkdir -p /mnt/storage/logs

#########################################
# SWAP
#########################################

echo "[6/13] Creating swap on SD Card..."

if [ ! -f /mnt/storage/swapfile ]; then

    fallocate -l 1G /mnt/storage/swapfile

    chmod 600 /mnt/storage/swapfile

    mkswap /mnt/storage/swapfile
fi

swapon /mnt/storage/swapfile || true

if ! grep -q "/mnt/storage/swapfile" /etc/fstab; then
    echo "/mnt/storage/swapfile none swap sw 0 0" >> /etc/fstab
fi

echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf

sysctl -p /etc/sysctl.d/99-swappiness.conf

#########################################
# NGINX
#########################################

echo "[7/13] Installing Nginx..."

apt install nginx -y

systemctl enable nginx

#########################################
# PHP
#########################################

echo "[8/13] Installing PHP..."

apt install -y \
php-fpm \
php-cli \
php-common \
php-curl \
php-mysql \
php-gd \
php-mbstring \
php-xml \
php-zip

#########################################
# MARIADB
#########################################

echo "[9/13] Installing MariaDB..."

apt install mariadb-server -y

systemctl enable mariadb
systemctl start mariadb

#########################################
# WEBSITE
#########################################

echo "[10/13] Creating website..."

cat > /var/www/html/index.php << 'EOF'
<?php

echo "<h1>B860H Hosting Server</h1>";
echo "<p>Powered by Armbian</p>";

?>
EOF

chown -R www-data:www-data /var/www/html

#########################################
# FILEBROWSER
#########################################

echo "[11/13] Installing FileBrowser..."

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

cat > /etc/systemd/system/filebrowser.service << 'EOF'
[Unit]
Description=FileBrowser
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/filebrowser \
-r /mnt/storage/files \
-p 8080

Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable filebrowser
systemctl restart filebrowser

#########################################
# FIREWALL + FAIL2BAN
#########################################

echo "[12/13] Security setup..."

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp

ufw --force enable

systemctl enable fail2ban
systemctl restart fail2ban

#########################################
# BACKUP
#########################################

echo "[13/13] Backup configuration..."

cat > /usr/local/bin/backup-web.sh << 'EOF'
#!/bin/bash

DATE=$(date +%F_%H-%M)

tar -czf \
/mnt/storage/backup/web-$DATE.tar.gz \
/var/www/html
EOF

chmod +x /usr/local/bin/backup-web.sh

cat > /usr/local/bin/backup-mariadb.sh << 'EOF'
#!/bin/bash

DATE=$(date +%F_%H-%M)

mysqldump --all-databases \
> /mnt/storage/backup/mysql-$DATE.sql
EOF

chmod +x /usr/local/bin/backup-mariadb.sh

(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-web.sh") | crontab -

(crontab -l 2>/dev/null; echo "30 2 * * * /usr/local/bin/backup-mariadb.sh") | crontab -

#########################################
# FINISH
#########################################

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "==========================================="
echo " INSTALLATION COMPLETE"
echo "==========================================="
echo ""
echo "Web      : http://$IP"
echo "Files    : http://$IP:8080"
echo ""
echo "Storage  : /mnt/storage"
echo "Backup   : /mnt/storage/backup"
echo ""
echo "NEXT:"
echo "mysql_secure_installation"
echo ""
echo "Install Cloudflared:"
echo ""
echo "apt install cloudflared"
echo "cloudflared tunnel login"
echo ""
