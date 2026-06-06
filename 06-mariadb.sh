#!/bin/bash

clear

echo "========================================="
echo "[6/10] INSTALL MARIADB"
echo "========================================="
echo ""

echo "MariaDB Database Server"
echo ""
echo "Digunakan untuk:"
echo "- Website Dinamis"
echo "- WordPress"
echo "- Dashboard"
echo "- PHP Application"
echo ""

read -p "Install MariaDB? [Y/N] : " CONFIRM

[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && exit 0

echo ""
echo "[INFO] Installing MariaDB..."
echo ""

apt install -y mariadb-server

systemctl enable mariadb
systemctl restart mariadb

DB_USER="budijoiadmin"
DB_PASS=$(tr -dc 'A-Za-z0-9@#$%&*' </dev/urandom | head -c 16)

mysql <<EOF
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost'
IDENTIFIED BY '$DB_PASS';

GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'localhost'
WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

echo ""
echo "========================================="
echo " MARIADB INSTALLED"
echo "========================================="
echo ""

echo "Root Login:"
echo "sudo mysql"
echo ""

echo "Database User:"
echo "$DB_USER"
echo ""

echo "Password:"
echo "$DB_PASS"
echo ""

echo "CATAT INFORMASI INI"
echo ""

cat >> /root/budijoi-server-info.txt << EOF

=========================================

MariaDB

Root Login:
sudo mysql

Database User:
$DB_USER

Password:
$DB_PASS

=========================================

EOF

read -p "Tekan ENTER setelah dicatat..."