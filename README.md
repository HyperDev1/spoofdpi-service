# SpoofDPI Service

SpoofDPI binary'sini macOS launchd servisi olarak çalıştırır.
Terminal açık kalmadan arka planda çalışır.

## ⚠️ Binary Kurulumu (Önce Yapılması Gerekir)

Binary'ler git'e eklenmez. Kurulumdan önce mimarinize uygun binary'yi indirmeniz gerekir:

```bash
# Intel Mac (x86_64)
curl -L -o spoofdpi https://github.com/xvzc/SpoofDPI/releases/latest/download/spoofdpi_darwin_x86_64.tar.gz
# veya
curl -L "$(curl -s https://api.github.com/repos/xvzc/SpoofDPI/releases/latest | grep browser_download_url | grep darwin_x86_64.tar.gz | grep -v sbom | cut -d'"' -f4)" | tar -xz spoofdpi

# Apple Silicon Mac (M1/M2/M3/M4/M5 — arm64)
curl -L "$(curl -s https://api.github.com/repos/xvzc/SpoofDPI/releases/latest | grep browser_download_url | grep darwin_arm64.tar.gz | grep -v sbom | cut -d'"' -f4)" | tar -xz spoofdpi
```

> **Not:** `install.sh` mimariyi otomatik algılar. Intel için `spoofdpi`, Apple Silicon için `spoofdpi-arm64` dosyasını arar.

## Hızlı Kurulum

```bash
git clone https://github.com/HyperDev1/spoofdpi-service.git
cd spoofdpi-service

# Mimarinize göre binary indirin (yukarıya bakın)

./install.sh
```

## Kullanım

```bash
spoofdpi-ctl start           # Servisi başlat
spoofdpi-ctl stop            # Servisi durdur
spoofdpi-ctl restart         # Yeniden başlat
spoofdpi-ctl status          # Durumu göster
spoofdpi-ctl log             # Son 50 satır log
spoofdpi-ctl log 100         # Son 100 satır log
spoofdpi-ctl log -f          # Logu canlı takip et
spoofdpi-ctl enable          # Login'de otomatik başlat
spoofdpi-ctl disable         # Otomatik başlatmayı kapat
```

## Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `spoofdpi` | SpoofDPI binary (Intel x86_64) — git'e eklenmez |
| `spoofdpi-arm64` | SpoofDPI binary (Apple Silicon arm64) — git'e eklenmez |
| `spoofdpi-ctl` | Servis yönetim CLI aracı |
| `com.spoofdpi.plist` | macOS LaunchAgent tanımı |
| `install.sh` | Kurulum betiği (mimariyi otomatik algılar) |

## Log Konumları

- Stdout: `/usr/local/var/log/spoofdpi/spoofdpi.log`
- Stderr: `/usr/local/var/log/spoofdpi/spoofdpi.error.log`

## Kaldırma

```bash
./install.sh --uninstall
```
