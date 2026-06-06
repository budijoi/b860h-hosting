#!/bin/bash

clear

echo "========================================="
echo "[5/10] INSTALL PHP"
echo "========================================="
echo ""

echo "PHP yang akan dipasang:"
echo ""
echo "PHP-FPM"
echo "PHP-CLI"
echo "PHP-MySQL"
echo "PHP-CURL"
echo "PHP-GD"
echo "PHP-XML"
echo ""

read -p "Install PHP? [Y/N] : " CONFIRM

[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && exit 0

apt install -y \
php-fpm \
php-cli \
php-common \
php-mysql \
php-curl \
php-gd \
php-mbstring \
php-xml \
php-zip

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

cat > /etc/nginx/sites-available/default << EOF
server {

    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {

        include snippets/fastcgi-php.conf;

        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;

    }

}
EOF

systemctl restart php${PHP_VERSION}-fpm
systemctl restart nginx

echo ""
echo "[✓] PHP Installed"
echo "[✓] PHP Version : $PHP_VERSION"
echo ""

read -p "Tekan ENTER..."