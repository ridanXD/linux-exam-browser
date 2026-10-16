#!/usr/bin/env bash
#
# Linux Exam Browser One-Line Remote Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ridanXD/linux-exam-browser/main/install.sh | bash
#

set -e

GITHUB_REPO="ridanXD/linux-exam-browser"

RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/latest/download"
RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main"

TARGET_BIN_DIR="${HOME}/.local/bin"
TARGET_BIN="${TARGET_BIN_DIR}/seb"
TARGET_ALIAS="${TARGET_BIN_DIR}/linux-seb"
TARGET_ICON_DIR="${HOME}/.local/share/icons/hicolor/scalable/apps"
TARGET_ICON="${TARGET_ICON_DIR}/linux-seb.svg"
TARGET_DESKTOP_DIR="${HOME}/.local/share/applications"
TARGET_DESKTOP="${TARGET_DESKTOP_DIR}/linux-seb.desktop"
TARGET_MIME_DIR="${HOME}/.local/share/mime/packages"
TARGET_MIME="${TARGET_MIME_DIR}/x-safeexambrowser.xml"

COLOR_GREEN="\033[0;32m"
COLOR_BLUE="\033[0;34m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[0;31m"
COLOR_RESET="\033[0m"

log_info() { echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $1"; }
log_ok()   { echo -e "${COLOR_GREEN}[OK]${COLOR_RESET} $1"; }
log_warn() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET} $1"; }
log_err()  { echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $1"; }

ARCH="$(uname -m)"
if [[ "${ARCH}" != "x86_64" ]]; then
    log_err "Arsitektur ${ARCH} belum didukung. Hanya x86_64 yang didukung saat ini."
    exit 1
fi

echo "=========================================="
echo "    Linux Exam Browser Installer via curl"
echo "=========================================="

# 1. Download AppImage binary
log_info "Mengunduh Linux Exam Browser AppImage..."
mkdir -p "${TARGET_BIN_DIR}"
curl -fSL --progress-bar "${RELEASE_URL}/Linux-SEB-x86_64.AppImage" -o "${TARGET_BIN}"
chmod +x "${TARGET_BIN}"
ln -sf seb "${TARGET_ALIAS}"
log_ok "Binary tersimpan di ${TARGET_BIN} (dan alias ${TARGET_ALIAS})"

# 2. Download Icon
log_info "Mengunduh icon..."
mkdir -p "${TARGET_ICON_DIR}"
curl -fsSL "${RAW_URL}/linux-seb.svg" -o "${TARGET_ICON}" || true
log_ok "Icon tersimpan."

# 3. Setup MIME type
log_info "Mendaftarkan MIME type file .seb..."
mkdir -p "${TARGET_MIME_DIR}"
cat << 'EOF' > "${TARGET_MIME}"
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-safeexambrowser">
    <comment>Linux Exam Browser Configuration</comment>
    <icon name="linux-seb"/>
    <glob pattern="*.seb"/>
  </mime-type>
  <mime-type type="application/seb">
    <comment>Linux Exam Browser Configuration</comment>
    <icon name="linux-seb"/>
    <glob pattern="*.seb"/>
  </mime-type>
</mime-info>
EOF

if command -v update-mime-database >/dev/null 2>&1; then
    update-mime-database "${HOME}/.local/share/mime" 2>/dev/null || true
fi

# 4. Create Desktop Entry
log_info "Membuat shortcut desktop & aplikasi..."
mkdir -p "${TARGET_DESKTOP_DIR}"
cat << EOF > "${TARGET_DESKTOP}"
[Desktop Entry]
Name=Linux Exam Browser
Comment=Linux Exam Browser
Exec=${TARGET_BIN} %f
Icon=linux-seb
Terminal=false
Type=Application
MimeType=application/x-safeexambrowser;application/seb;
Categories=Education;Network;WebBrowser;
StartupWMClass=linux-seb
EOF
chmod +x "${TARGET_DESKTOP}"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${TARGET_DESKTOP_DIR}" 2>/dev/null || true
fi

if command -v xdg-mime >/dev/null 2>&1; then
    xdg-mime default linux-seb.desktop application/x-safeexambrowser 2>/dev/null || true
    xdg-mime default linux-seb.desktop application/seb 2>/dev/null || true
fi
log_ok "Desktop entry dan MIME association selesai."

# 5. Check PATH
echo ""
log_ok "Instalasi selesai!"
echo "------------------------------------------"
if [[ ":$PATH:" != *":${TARGET_BIN_DIR}:"* ]]; then
    log_warn "${TARGET_BIN_DIR} belum ada di dalam PATH kamu."
    echo "Tambahkan baris berikut ke ~/.bashrc atau ~/.zshrc agar perintah 'seb' bisa langsung dipanggil:"
    echo -e "${COLOR_GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${COLOR_RESET}"
    echo ""
else
    log_info "Perintah '${COLOR_GREEN}seb <file.seb>${COLOR_RESET}' (atau '${COLOR_GREEN}linux-seb <file.seb>${COLOR_RESET}') sudah aktif dan bisa langsung digunakan!"
fi

echo "Kamu juga bisa langsung klik dua kali file .seb di File Manager."
echo "=========================================="
