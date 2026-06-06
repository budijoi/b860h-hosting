#!/bin/bash

clear

echo "========================================="
echo "[4/10] INSTALL NGINX"
echo "========================================="
echo ""

echo "NGINX akan digunakan sebagai:"
echo ""
echo "- Web Server"
echo "- Reverse Proxy"
echo "- PHP Frontend"
echo ""

read -p "Install NGINX? [Y/N] : " CONFIRM

[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && exit 0

apt install -y nginx

systemctl enable nginx
systemctl restart nginx

echo ""

if systemctl is-active --quiet nginx
then
    echo "[✓] NGINX Running"
else
    echo "[✗] NGINX Failed"
fi

read -p "Tekan ENTER..."