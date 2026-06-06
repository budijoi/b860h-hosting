## Ringkasan Arsitektur Final

```text
B860H V1
│
├── eMMC (8GB)
│   ├── Armbian
│   ├── Nginx
│   ├── PHP-FPM
│   ├── MariaDB
│   ├── FileBrowser
│   ├── Fail2Ban
│   ├── UFW
│   └── Cloudflared
│
└── microSD
    ├── files
    ├── media
    ├── backup
    ├── website-data
    ├── logs
    ├── filebrowser
    │   └── filebrowser.db
    └── swapfile
```

## Kondisi Perangkat yang Sudah Terbukti

```text
eMMC    : /dev/mmcblk2p2
microSD : /dev/mmcblk1p2
RAM     : 1GB
OS      : Armbian
```

## Target Installer

Installer harus:

✅ Deteksi otomatis root filesystem
✅ Deteksi otomatis SD Card ext4
✅ Mount otomatis ke `/mnt/storage`
✅ Membuat swap 1GB di SD Card
✅ Install Nginx
✅ Install PHP-FPM
✅ Install MariaDB
✅ Install FileBrowser (database di SD Card)
✅ Install UFW + Fail2Ban
✅ Backup Website otomatis
✅ Backup MariaDB otomatis
✅ Menampilkan progress dan informasi yang jelas

---

Installer otomatis untuk mengubah STB ZTE B860H V1 menjadi server hosting ringan berbasis Armbian.

## Fitur

* Nginx
* PHP-FPM
* MariaDB
* FileBrowser
* UFW Firewall
* Fail2Ban
* Auto Backup
* SD Card Storage
* Swap di SD Card

## Struktur Storage

eMMC:

* Armbian
* Nginx
* PHP
* MariaDB
* FileBrowser

microSD:

* /mnt/storage/files
* /mnt/storage/media
* /mnt/storage/backup
* /mnt/storage/website-data
* /mnt/storage/logs
* /mnt/storage/filebrowser
* /mnt/storage/swapfile

## Instalasi manual

chmod +x install.sh

./install.sh

## Cek Service

systemctl status nginx

systemctl status mariadb

systemctl status filebrowser

## Cek Swap

swapon --show

free -h

## Website Root

/var/www/html

atau

/mnt/storage/website-data/site1

## FileBrowser

[http://IP-STB:8080](http://IP-STB:8080)

Default Login:

admin
admin12345678

Segera ganti password setelah login.

---

## Instalasi Otomatis
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/budijoi/b860h-hosting/refs/heads/main/install.sh)
```

## Setelah Instalasi Selesai

### 1. Cek Service

```bash
systemctl status nginx
systemctl status mariadb
systemctl status filebrowser
```

Semua harus:

```text
active (running)
```

---

## 2. Cara Mengamankan MariaDB

Pada MariaDB terbaru:

```bash
which mariadb-secure-installation
```

Jika ada:

```bash
mariadb-secure-installation
```

Jika tidak ada, MariaDB tetap aman menggunakan autentikasi socket bawaan Linux root.

Cek:

```bash
mariadb
```

---

## 3. Cara Install Cloudflared

Karena Armbian ARM64 sering tidak memiliki paket bawaan:

```bash
cd /tmp

wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64

chmod +x cloudflared-linux-arm64

mv cloudflared-linux-arm64 /usr/local/bin/cloudflared
```

Cek:

```bash
cloudflared version
```

---

## Login Cloudflare

```bash
cloudflared tunnel login
```

Akan muncul URL.

Buka URL tersebut di browser.

Pilih domain Cloudflare yang ingin digunakan.

---

## Membuat Tunnel

```bash
cloudflared tunnel create b860h
```

---

## Konfigurasi Tunnel

```bash
mkdir -p ~/.cloudflared

nano ~/.cloudflared/config.yml
```

Contoh:

```yaml
tunnel: TUNNEL-ID
credentials-file: /root/.cloudflared/TUNNEL-ID.json

ingress:

  - hostname: web.domain.com
    service: http://localhost:80

  - hostname: files.domain.com
    service: http://localhost:8080

  - service: http_status:404
```

---

## Hubungkan DNS

```bash
cloudflared tunnel route dns b860h web.domain.com

cloudflared tunnel route dns b860h files.domain.com
```

---

## Install Service Cloudflared

```bash
cloudflared service install

systemctl enable cloudflared

systemctl start cloudflared
```

---

## Cara Edit Website

### Edit langsung

```bash
nano /var/www/html/index.php
```

atau

```bash
nano /var/www/html/index.html
```

---

### Pindahkan Website ke SD Card

Buat folder:

```bash
mkdir -p /mnt/storage/website-data/site1
```

Edit Nginx:

```bash
nano /etc/nginx/sites-available/default
```

Cari:

```nginx
root /var/www/html;
```

Ganti:

```nginx
root /mnt/storage/website-data/site1;
```

Reload:

```bash
nginx -t

systemctl reload nginx
```

---

## Upload Website Melalui FileBrowser

Buka:

```text
http://IP-STB:8080
```

Upload ke:

```text
/mnt/storage/website-data/site1
```

Maka website langsung dapat dilayani oleh Nginx.

---

## Backup Manual

Website:

```bash
/usr/local/bin/backup-web.sh
```

Database:

```bash
/usr/local/bin/backup-mariadb.sh
```

---

## Jadwal Backup Otomatis

```text
02:00 Backup Website
02:30 Backup MariaDB
```

Lokasi:

```text
/mnt/storage/backup
```

---

## Target Penggunaan

Cocok untuk:

* Landing Page
* Website Profil Perusahaan
* Blog WordPress Ringan
* File Sharing Keluarga
* Backup Foto dan Video
* Server Rumahan 24/7

Perkiraan penggunaan:

eMMC:

* 2.5–4 GB

RAM Idle:

* 300–500 MB

Sisa RAM:

* ±0.5 GB

Sisa Storage SD:

* ±56 GB (dengan SD 64GB)
  :::
