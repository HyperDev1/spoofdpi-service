# SpoofDPI Service

SpoofDPI binary'sini macOS launchd servisi olarak çalıştırır.
Terminal açık kalmadan arka planda çalışır.

## Kurulum

```bash
# 1. Binary'yi sisteme kopyala
cp spoofdpi /usr/local/bin/spoofdpi
chmod +x /usr/local/bin/spoofdpi

# 2. Log dizini oluştur
mkdir -p /usr/local/var/log/spoofdpi

# 3. CLI aracını kopyala
cp spoofdpi-ctl /usr/local/bin/spoofdpi-ctl
chmod +x /usr/local/bin/spoofdpi-ctl

# 4. LaunchAgent plist'i yerleştir
cp com.spoofdpi.plist ~/Library/LaunchAgents/

# 5. Servisi yükle
launchctl load ~/Library/LaunchAgents/com.spoofdpi.plist
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
| `spoofdpi` | SpoofDPI binary |
| `spoofdpi-ctl` | Servis yönetim CLI aracı |
| `com.spoofdpi.plist` | macOS LaunchAgent tanımı |

## Log Konumları

- Stdout: `/usr/local/var/log/spoofdpi/spoofdpi.log`
- Stderr: `/usr/local/var/log/spoofdpi/spoofdpi.error.log`
