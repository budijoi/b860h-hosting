#!/bin/bash

clear

echo "========================================="
echo "[7/10] INSTALL FILE BROWSER"
echo "========================================="
echo ""

echo "File Browser akan digunakan untuk:"
echo "- Upload File"
echo "- Download File"
echo "- Kelola Storage via Web Browser"
echo ""

read -p "Install File Browser? [Y/N] : " CONFIRM

[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && exit 0

CONFIG_FILE="/etc/budijoi-server.conf"

if [ -f "$CONFIG_FILE" ]; then
source "$CONFIG_FILE"
fi

SERVER_IP=$(hostname -I | awk '{print $1}')
FILEBROWSER_USER="admin"

generate_password() {
tr -dc 'A-Za-z0-9@#$%&*' </dev/urandom | head -c 16
}

FILEBROWSER_PASS=$(generate_password)

STORAGE_PATH=${STORAGE_PATH:-/mnt/storage}

echo ""
echo "[INFO] Preparing storage folders..."
echo ""

mkdir -p "$STORAGE_PATH"/{public,private,backup,web,share}

echo ""
echo "[INFO] Detecting architecture..."
echo ""

ARCH=$(uname -m)

case "$ARCH" in
aarch64)
FB_ARCH="linux-arm64"
;;
x86_64)
FB_ARCH="linux-amd64"
;;
armv7l)
FB_ARCH="linux-armv7"
;;
*)
echo "[ERROR] Unsupported architecture: $ARCH"
exit 1
;;
esac

FILEBROWSER_VERSION="v2.44.0"

TMP_DIR="/tmp/filebrowser-install"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

cd "$TMP_DIR"

echo ""
echo "[INFO] Downloading File Browser..."
echo ""

wget -O filebrowser.tar.gz 
https://github.com/filebrowser/filebrowser/releases/download/${FILEBROWSER_VERSION}/${FB_ARCH}-filebrowser.tar.gz

if [ $? -ne 0 ]; then
echo "[ERROR] Download failed."
exit 1
fi

echo ""
echo "[INFO] Extracting..."
echo ""

tar -xzf filebrowser.tar.gz

install -m 755 filebrowser /usr/local/bin/filebrowser

mkdir -p /etc/filebrowser

echo ""
echo "[INFO] Creating database..."
echo ""

cat > /etc/filebrowser/settings.json <<EOF
{
"port": 8080,
"baseURL": "/",
"address": "127.0.0.1",
"log": "stdout",
"database": "/etc/filebrowser/filebrowser.db",
"root": "$STORAGE_PATH"
}
EOF

/usr/local/bin/filebrowser config init 
-d /etc/filebrowser/filebrowser.db

/usr/local/bin/filebrowser config set 
-r "$STORAGE_PATH" 
-d /etc/filebrowser/filebrowser.db

/usr/local/bin/filebrowser users add 
"$FILEBROWSER_USER" 
"$FILEBROWSER_PASS" 
--perm.admin 
-d /etc/filebrowser/filebrowser.db

echo ""
echo "[INFO] Creating systemd service..."
echo ""

cat > /etc/systemd/system/filebrowser.service <<EOF
[Unit]
Description=File Browser
After=network.target

[Service]
User=root
Group=root

ExecStart=/usr/local/bin/filebrowser 
-r $STORAGE_PATH 
-a 127.0.0.1 
-p 8080 
-d /etc/filebrowser/filebrowser.db

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable filebrowser
systemctl restart filebrowser

echo ""
echo "[INFO] Saving configuration..."
echo ""

grep -q "^FILEBROWSER_USER=" "$CONFIG_FILE" 2>/dev/null || 
echo "FILEBROWSER_USER=$FILEBROWSER_USER" >> "$CONFIG_FILE"

grep -q "^FILEBROWSER_PASS=" "$CONFIG_FILE" 2>/dev/null || 
echo "FILEBROWSER_PASS=$FILEBROWSER_PASS" >> "$CONFIG_FILE"

cat >> /root/budijoi-server-info.txt <<EOF

=========================================

File Browser

URL:
http://$SERVER_IP/files

Internal URL:
http://127.0.0.1:8080

Username:
$FILEBROWSER_USER

Password:
$FILEBROWSER_PASS

Storage:
$STORAGE_PATH

=========================================

EOF

clear

echo "========================================="
echo " FILE BROWSER INSTALLED"
echo "========================================="
echo ""

echo "URL"
echo "http://$SERVER_IP/files"
echo ""

echo "Username"
echo "$FILEBROWSER_USER"
echo ""

echo "Password"
echo "$FILEBROWSER_PASS"
echo ""

echo "Storage Path"
echo "$STORAGE_PATH"
echo ""

echo "========================================="
echo "CATAT INFORMASI INI"
echo "========================================="
echo ""

read -p "Tekan ENTER setelah dicatat..."
