#!/bin/bash

set -e

clear

echo "========================================="
echo " B860H HOSTING EDITION V4"
echo "========================================="

if [ "$EUID" -ne 0 ]; then
    echo "Jalankan sebagai root"
    exit 1
fi

#########################################
# VALIDASI ROOTFS
#########################################

ROOT_DEV=$(findmnt -n -o SOURCE /)

if [[ "$ROOT_DEV" != "/dev/mmcblk2p2" ]]; then
    echo ""
    echo "ERROR:"
    echo "Root filesystem bukan eMMC."
    echo "Script ini dibuat untuk layout:"
    echo "/dev/mmcblk2p2 = eMMC"
    echo ""
    exit 1
fi

#########################################
# VALIDASI STORAGE
#########################################

if ! mountpoint -q /mnt/storage; then

    echo ""
    echo "ERROR:"
    echo "/mnt/storage belum ter-mount"
    echo ""
    exit 1
fi

#########################################
# UPDATE
#########################################

apt update
apt upgrade -y

#########################################
# BASIC TOOLS
#########################################

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
# SWAP
#########################################

if [ ! -f /mnt/storage/swapfile ]; then

    fallocate -l 1G /mnt/storage/swapfile

    chmod 600 /mnt/storage/swapfile

    mkswap /mnt/storage/swapfile
fi

swapon /mnt/storage/swapfile || true

grep -q swapfile /etc/fstab || \
echo "/mnt/storage/swapfile none swap sw 0 0" >> /etc/fstab

echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf

sysctl -p /etc/sysctl.d/99-swappiness.conf

#########################################
# NGINX
#########################################

apt install nginx -y

systemctl enable nginx

#########################################
# PHP
#########################################

apt install -y \
php-fpm \
php-cli \
php-common \
php-curl \
php-gd \
php-mysql \
php-mbstring \
php-xml \
php-zip

#########################################
# PHP TUNING
#########################################

PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

PHP_INI="/etc/php/$PHP_VER/fpm/php.ini"

sed -i 's/memory_limit = .*/memory_limit = 128M/' $PHP_INI
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 512M/' $PHP_INI
sed -i 's/post_max_size = .*/post_max_size = 512M/' $PHP_INI

systemctl restart php${PHP_VER}-fpm

#########################################
# MARIADB
#########################################

apt install mariadb-server -y

systemctl enable mariadb
systemctl start mariadb

#########################################
# WEBSITE
#########################################

mkdir -p /var/www/html

cat > /var/www/html/index.php << 'EOF'
<?php
phpinfo();
?>
EOF

chown -R www-data:www-data /var/www/html

#########################################
# FILEBROWSER
#########################################

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

id filebrowser >/dev/null 2>&1 || \
useradd -r -s /usr/sbin/nologin filebrowser

chown -R filebrowser:filebrowser /mnt/storage/files

cat > /etc/systemd/system/filebrowser.service << 'EOF'
[Unit]
Description=FileBrowser
After=network.target

[Service]
User=filebrowser
Group=filebrowser

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
# FIREWALL
#########################################

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp

ufw --force enable

#########################################
# FAIL2BAN
#########################################

systemctl enable fail2ban
systemctl restart fail2ban

#########################################
# BACKUP SCRIPT
#########################################

cat > /usr/local/bin/backup-web.sh << 'EOF'
#!/bin/bash

DATE=$(date +%F_%H-%M)

tar -czf \
/mnt/storage/backup/web-$DATE.tar.gz \
/var/www/html
EOF

chmod +x /usr/local/bin/backup-web.sh

cat > /usr/local/bin/backup-db.sh << 'EOF'
#!/bin/bash

DATE=$(date +%F_%H-%M)

mysqldump --all-databases \
> /mnt/storage/backup/db-$DATE.sql
EOF

chmod +x /usr/local/bin/backup-db.sh

(crontab -l 2>/dev/null | grep -v backup-web.sh; \
echo "0 2 * * * /usr/local/bin/backup-web.sh") | crontab -

(crontab -l 2>/dev/null | grep -v backup-db.sh; \
echo "30 2 * * * /usr/local/bin/backup-db.sh") | crontab -

#########################################
# INFO
#########################################

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "====================================="
echo "INSTALLATION COMPLETE"
echo "====================================="
echo ""
echo "Web:"
echo "http://$IP"
echo ""
echo "FileBrowser:"
echo "http://$IP:8080"
echo ""
echo "Storage:"
echo "/mnt/storage"
echo ""
echo "Next:"
echo "mysql_secure_installation"
echo "Install Cloudflared"
echo ""
