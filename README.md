Untuk B860H V1 yang RAM-nya terbatas, kita buat versi ringan dan fokus untuk:

Optimasi Armbian
Nginx
PHP 8.2
MariaDB
FileBrowser
UFW Firewall
Fail2Ban
Swap 1GB
Folder hosting siap pakai

Cloudflare Tunnel sengaja tidak di otomatisasi, karena tetap memerlukan login akun Cloudflare dan pemilihan domain secara manual.

Yang perlu di siapkan :
1. STB B860H V1 yang sudah di root dan terinstall Armbian.
2. SDCARD sebagai media storage/penyimpanan.
3. Domain, gunakan yang paling murah dulu seperti .my.id
4. Koneksi Internet

Jadi OS Armbian harus terinstall di internal EMMC. Strukturnya kira-kira seperti ini :

```eMMC
├── Armbian
├── Nginx
├── PHP-FPM
├── MariaDB
├── FileBrowser
├── Fail2Ban
├── Cloudflared (manual install)
└── Sistem

microSD
└── /mnt/storage
    ├── files
    ├── media
    ├── backup
    ├── website-data
    ├── logs
    └── swapfile
```

✅ Auto mount SD Card
✅ Swap 1GB di SD Card
✅ Swappiness = 10
✅ Nginx
✅ PHP
✅ MariaDB
✅ FileBrowser
✅ UFW
✅ Fail2Ban
✅ Backup Website Harian
✅ Backup Database Harian
✅ Struktur folder siap pakai

#Keuntungannya:
eMMC lebih cepat untuk OS
microSD mudah diganti saat penuh
Jika Armbian rusak, data file tetap aman di SD Card
Backup lebih mudah.

Ok, kita mulai

#Langkah 1 - Aktifkan STB

Nyalakan dan hubungkan STB ke router, lalu akses melalui SSH (contoh: putty)
Hostname: isi dengan IP STB, lihat IP nya di dalam pengaturan router
Port: 22
Login as: root
Password: 1234

#Langkah 2 - Instalasi Script

`wget -qO- https://raw.githubusercontent.com/budijoi/Script-Installer-Web-Hosting-B860H/refs/heads/main/sc-v1.sh | bash`

atau

`bash <(curl -fsSL https://raw.githubusercontent.com/budijoi/Script-Installer-Web-Hosting-B860H/refs/heads/main/sc-v1.sh.sh)`

Tunggu hingga proses selesai.
