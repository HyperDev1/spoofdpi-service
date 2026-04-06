#!/usr/bin/env bash
# install.sh — SpoofDPI servis kurulum betiği

set -euo pipefail

# ── Renkler ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
err()  { echo -e "  ${RED}✗${RESET} $*" >&2; }
info() { echo -e "  ${CYAN}→${RESET} $*"; }
warn() { echo -e "  ${YELLOW}!${RESET} $*"; }
step() { echo -e "\n${BOLD}$*${RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Quarantine etiketlerini kaldır (Gatekeeper engeli) ────────────────────────
xattr -cr "$SCRIPT_DIR" 2>/dev/null || true

# ── Mimari tespiti ─────────────────────────────────────────────────────────────
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
    BINARY_NAME="spoofdpi-arm64"
else
    BINARY_NAME="spoofdpi"
fi

BINARY_SRC="$SCRIPT_DIR/$BINARY_NAME"
CTL_SRC="$SCRIPT_DIR/spoofdpi-ctl"
PLIST_SRC="$SCRIPT_DIR/com.spoofdpi.plist"

BIN_DIR="/opt/homebrew/bin"
# Apple Silicon'da /opt/homebrew/var, Intel'de /usr/local/var
if [[ -d "/opt/homebrew/var" ]]; then
    LOG_DIR="/opt/homebrew/var/log/spoofdpi"
elif [[ -d "/usr/local/var" ]]; then
    LOG_DIR="/usr/local/var/log/spoofdpi"
else
    LOG_DIR="/opt/homebrew/var/log/spoofdpi"
fi
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_DEST="$LAUNCH_AGENTS_DIR/com.spoofdpi.plist"
LABEL="com.spoofdpi"

# ── Banner ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}  ┌─────────────────────────────────┐${RESET}"
echo -e "${BOLD}  │     SpoofDPI Servis Kurulumu     │${RESET}"
echo -e "${BOLD}  └─────────────────────────────────┘${RESET}"
echo ""

# ── Uninstall modu ─────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--uninstall" ]]; then
    step "[1/3] Servis durduruluyor..."
    if launchctl list "$LABEL" &>/dev/null; then
        launchctl stop "$LABEL" 2>/dev/null || true
        launchctl unload "$PLIST_DEST" 2>/dev/null || true
        ok "Servis durduruldu ve kaldırıldı"
    else
        warn "Servis zaten yüklü değil"
    fi

    step "[2/3] Dosyalar siliniyor..."
    rm -f "$BIN_DIR/spoofdpi"     && ok "spoofdpi silindi"     || warn "spoofdpi bulunamadı"
    rm -f "$BIN_DIR/spoofdpi-ctl" && ok "spoofdpi-ctl silindi" || warn "spoofdpi-ctl bulunamadı"
    rm -f "$PLIST_DEST"           && ok "plist silindi"        || warn "plist bulunamadı"

    step "[3/3] Log dizini..."
    if [[ -d "$LOG_DIR" ]]; then
        read -rp "  Log dizini silinsin mi? ($LOG_DIR) [e/H] " confirm
        if [[ "$confirm" =~ ^[Ee]$ ]]; then
            rm -rf "$LOG_DIR" && ok "Log dizini silindi"
        else
            warn "Log dizini bırakıldı"
        fi
    fi

    echo ""
    echo -e "  ${GREEN}${BOLD}Kaldırma tamamlandı.${RESET}"
    echo ""
    exit 0
fi

# ── Ön kontroller ──────────────────────────────────────────────────────────────
step "[0/5] Kontroller..."

[[ ! -f "$BINARY_SRC" ]] && { err "spoofdpi binary bulunamadı: $BINARY_SRC (mimari: $ARCH)"; exit 1; }
[[ ! -f "$CTL_SRC" ]]    && { err "spoofdpi-ctl bulunamadı: $CTL_SRC"; exit 1; }
[[ ! -f "$PLIST_SRC" ]]  && { err "com.spoofdpi.plist bulunamadı: $PLIST_SRC"; exit 1; }
ok "Kaynak dosyalar mevcut"

# ── Zaten kurulu mu? ───────────────────────────────────────────────────────────
if [[ -f "$BIN_DIR/spoofdpi" ]] || [[ -f "$PLIST_DEST" ]]; then
    warn "SpoofDPI zaten kurulu görünüyor."
    read -rp "  Üzerine yazılsın mı? [e/H] " confirm
    [[ "$confirm" =~ ^[Ee]$ ]] || { echo "  İptal edildi."; exit 0; }
fi

# ── [1] Binary'ler ─────────────────────────────────────────────────────────────
step "[1/5] Binary'ler kopyalanıyor... (${ARCH})"
cp "$BINARY_SRC" "$BIN_DIR/spoofdpi"
chmod +x "$BIN_DIR/spoofdpi"
ok "spoofdpi → $BIN_DIR/spoofdpi"

cp "$CTL_SRC" "$BIN_DIR/spoofdpi-ctl"
chmod +x "$BIN_DIR/spoofdpi-ctl"
ok "spoofdpi-ctl → $BIN_DIR/spoofdpi-ctl"

# ── [2] Log dizini ─────────────────────────────────────────────────────────────
step "[2/5] Log dizini oluşturuluyor..."
mkdir -p "$LOG_DIR"
ok "$LOG_DIR"

# ── [3] LaunchAgent ────────────────────────────────────────────────────────────
step "[3/5] LaunchAgent yükleniyor..."
mkdir -p "$LAUNCH_AGENTS_DIR"

# Eğer önceden yüklüyse kaldır
if launchctl list "$LABEL" &>/dev/null; then
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
    info "Önceki servis kaldırıldı"
fi

cp "$PLIST_SRC" "$PLIST_DEST"

# Binary ve log yollarını plist'te güncelle
/usr/libexec/PlistBuddy -c "Set :ProgramArguments:0 $BIN_DIR/spoofdpi" "$PLIST_DEST"
/usr/libexec/PlistBuddy -c "Set :StandardOutPath $LOG_DIR/spoofdpi.log" "$PLIST_DEST"
/usr/libexec/PlistBuddy -c "Set :StandardErrorPath $LOG_DIR/spoofdpi.error.log" "$PLIST_DEST"
ok "plist → $PLIST_DEST"

launchctl load "$PLIST_DEST"
ok "LaunchAgent yüklendi"

# ── [4] Otomatik başlatma sorusu ───────────────────────────────────────────────
step "[4/5] Otomatik başlatma..."
read -rp "  Login'de otomatik başlasın mı? [E/h] " autostart
if [[ ! "$autostart" =~ ^[Hh]$ ]]; then
    /usr/libexec/PlistBuddy -c "Set :RunAtLoad true" "$PLIST_DEST"
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
    launchctl load "$PLIST_DEST"
    ok "Otomatik başlatma aktif"
else
    warn "Otomatik başlatma devre dışı (elle başlatmak için: spoofdpi-ctl start)"
fi

# ── [5] İlk başlatma ───────────────────────────────────────────────────────────
step "[5/5] Servis başlatılıyor..."
if launchctl kickstart -k "gui/$(id -u)/$LABEL" &>/dev/null 2>&1; then
    true
else
    launchctl start "$LABEL" 2>/dev/null || true
fi
sleep 0.8

PID=$(launchctl list "$LABEL" 2>/dev/null | grep '"PID"' | grep -oE '[0-9]+' || true)
if [[ -n "$PID" ]]; then
    ok "SpoofDPI çalışıyor (PID: $PID)"
else
    warn "Servis başlamadı — log kontrol et: spoofdpi-ctl log"
fi

# ── Özet ───────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}  ┌─────────────────────────────────────────────┐${RESET}"
echo -e "${BOLD}  │           ${GREEN}Kurulum tamamlandı!${RESET}${BOLD}               │${RESET}"
echo -e "${BOLD}  └─────────────────────────────────────────────┘${RESET}"
echo ""
echo -e "  Kullanım:"
echo -e "    ${CYAN}spoofdpi-ctl start${RESET}      Servisi başlat"
echo -e "    ${CYAN}spoofdpi-ctl stop${RESET}       Servisi durdur"
echo -e "    ${CYAN}spoofdpi-ctl restart${RESET}    Yeniden başlat"
echo -e "    ${CYAN}spoofdpi-ctl status${RESET}     Durum göster"
echo -e "    ${CYAN}spoofdpi-ctl log -f${RESET}     Canlı log takibi"
echo ""
echo -e "  Kaldırmak için:"
echo -e "    ${CYAN}./install.sh --uninstall${RESET}"
echo ""
