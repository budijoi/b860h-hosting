# B860H HomeServer Installer

Ubah STB Android bekas menjadi Home Server ringan berbasis Armbian Linux.

Dirancang khusus untuk perangkat seperti:

* ZTE B860H v1
* Amlogic S905X
* Armbian

---

## Tentang Project

B860H HomeServer Installer adalah script instalasi interaktif yang dirancang untuk mempermudah proses mengubah STB Android bekas menjadi Home Server yang siap digunakan.

Installer akan memandu pengguna langkah demi langkah dan melakukan konfigurasi secara otomatis, sehingga cocok digunakan oleh pemula maupun pengguna yang sudah berpengalaman.

---

## Fitur Utama

### Deteksi Otomatis

* Deteksi Root Filesystem
* Deteksi Storage Tambahan
* Mount Storage Otomatis
* Deteksi IP Address Otomatis

### Web Server

* NGINX
* PHP-FPM
* MariaDB

### File Manager

* File Browser berbasis Web
* Upload dan Download File
* Manajemen File melalui Browser

### Monitoring Server

Menampilkan informasi:

* Hostname
* Kernel Linux
* Uptime
* CPU Load
* Suhu CPU
* Penggunaan RAM
* Penggunaan Swap
* Penggunaan Storage

### Halaman Otomatis

Installer akan membuat:

* Landing Page
* Status Monitoring
* Tutorial Instalasi

---

## Perangkat yang Telah Diuji

### Tested

* ZTE B860H v1
* Amlogic S905X
* RAM 1 GB
* EMMC 8 GB
* SDCARD 64 GB
* Armbian

### Kemungkinan Kompatibel

* STB berbasis S905X
* STB berbasis S905W

---

## Struktur Installer

```text
install.sh

modules/
├── 01-system.sh
├── 02-storage.sh
├── 03-swap.sh
├── 04-nginx.sh
├── 05-php.sh
├── 06-mariadb.sh
├── 07-filebrowser.sh
├── 08-firewall.sh (inprogress)
├── 09-landingpage.sh (inprogress)
└── 10-finish.sh (inprogress)
```

---

## Cara Instalasi

Clone repository:

```bash
git clone https://github.com/budijoi/b860h-hosting.git
```

Masuk ke dalam folder
```bash
cd b860h-hosting
```

Berikan izin eksekusi:
```bash
chmod +x install.sh
```

Jalankan installer:
```bash
sudo ./install.sh
```

---

## Tahapan Instalasi

### 1. System Preparation

* Update Repository
* Upgrade Sistem
* Install Dependensi Dasar

### 2. Storage Detection

* Deteksi Root Filesystem
* Deteksi Storage Tambahan
* Konfigurasi Mount Point

### 3. Swap Configuration

Pilihan:

* 512MB
* 1GB
* 2GB

### 4. Install NGINX

Instalasi dan konfigurasi Web Server.

### 5. Install PHP-FPM

Instalasi PHP untuk menjalankan aplikasi web.

### 6. Install MariaDB

Installer akan:

* Menginstall MariaDB
* Membuat user database
* Membuat password acak
* Menampilkan password untuk dicatat

### 7. Install File Browser

Installer akan:

* Menginstall File Browser
* Membuat akun admin
* Membuat password acak
* Menampilkan password untuk dicatat

### 8. Konfigurasi Firewall

Membuka port yang diperlukan.

### 9. Generate Web Pages

Membuat:

* index.html
* status.php
* tutorial.html

### 10. Finish

Menampilkan ringkasan hasil instalasi.

---

## URL Setelah Instalasi

Landing Page:

```text
http://IP-SERVER/
```

Status Monitoring:

```text
http://IP-SERVER/status.php
```

Tutorial:

```text
http://IP-SERVER/tutorial.html
```

File Browser:

```text
http://IP-SERVER/files
```

---

## Informasi Login

Semua informasi penting akan disimpan ke:

```text
/root/budijoi-server-info.txt
```

File tersebut berisi:

* Informasi Server
* Username dan Password MariaDB
* Username dan Password File Browser
* Informasi Storage
* Informasi Swap

---

## Screenshot

### Landing Page

Tambahkan screenshot di sini.

### Status Monitoring

Tambahkan screenshot di sini.

### Tutorial

Tambahkan screenshot di sini.

### File Browser

Tambahkan screenshot di sini.

---

## Roadmap

### Versi 1.0

* NGINX
* PHP-FPM
* MariaDB
* File Browser
* Monitoring Server

### Versi 2.0

* SSL / HTTPS
* Virtual Host Manager
* Backup Otomatis
* Multi Website Hosting

### Versi 3.0

* Docker Support
* Reverse Proxy Manager
* Dashboard Monitoring

---

## Lisensi

MIT License

---

## Author

B860H HomeServer Project
Powered by Armbian Linux
