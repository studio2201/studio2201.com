#!/bin/sh
# studio2201 universal installer
# Installs studio2201 tools (vigil, snip, boneyard, aegis, proven)
# Zero root required · installs to ~/.local/bin by default
set -e

REPO_OWNER="studio2201"
DEFAULT_DEST="${HOME}/.local/bin"
DEST_DIR="${INSTALL_DIR:-$DEFAULT_DEST}"
ALL_APPS="vigil snip boneyard aegis proven"

# Formatting helpers
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD="\033[1m" GREEN="\033[32m" YELLOW="\033[33m" RED="\033[31m" CYAN="\033[36m" RESET="\033[0m"
else
  BOLD="" GREEN="" YELLOW="" RED="" CYAN="" RESET=""
fi

info() { printf "${CYAN}==>${RESET} ${BOLD}%s${RESET}\n" "$1"; }
success() { printf "${GREEN}==>${RESET} %s\n" "$1"; }
warn() { printf "${YELLOW}warning:${RESET} %s\n" "$1" >&2; }
err() { printf "${RED}error:${RESET} %s\n" "$1" >&2; }

usage() {
  cat <<EOF
studio2201 installer

Usage:
  install.sh [OPTIONS] <APP | all>

Applications:
  vigil     Supply-chain dormancy scanner
  snip      Vibe-code security gate
  boneyard  Org-wide tech-debt radar
  aegis     PQC migration SDK (OMB M-26-15)
  proven    PQC-signed supply-chain attestor
  all       Install all 5 applications

Options:
  --dest <DIR>  Install directory (default: ~/.local/bin)
  -h, --help    Show this help message
  -V, --version Show installer version

Examples:
  curl -fsSL https://studio2201.com/install.sh | sh -s vigil
  curl -fsSL https://studio2201.com/install.sh | sh -s all
  sh install.sh --dest /usr/local/bin all
EOF
  exit 0
}

cleanup() { [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

detect_target() {
  OS="$(uname -s 2>/dev/null || true)"
  ARCH="$(uname -m 2>/dev/null || true)"

  case "$OS" in
    Linux)
      case "$ARCH" in
        x86_64) TARGET="x86_64-unknown-linux-musl" ;;
        aarch64|arm64) TARGET="aarch64-unknown-linux-musl" ;;
        *) TARGET="" ;;
      esac ;;
    Darwin)
      case "$ARCH" in
        x86_64) TARGET="x86_64-apple-darwin" ;;
        arm64|aarch64) TARGET="aarch64-apple-darwin" ;;
        *) TARGET="" ;;
      esac ;;
    *)
      TARGET="" ;;
  esac
}

download_file() {
  URL="$1"
  OUTPUT="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$URL" -o "$OUTPUT"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$URL" -O "$OUTPUT"
  else
    err "Neither curl nor wget found in PATH."
    return 1
  fi
}

verify_checksum() {
  FILE="$1"
  EXPECTED_SHA="$2"
  ACTUAL_SHA=""

  if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL_SHA="$(sha256sum "$FILE" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    ACTUAL_SHA="$(shasum -a 256 "$FILE" | awk '{print $1}')"
  else
    warn "sha256sum / shasum not available; skipping checksum verification."
    return 0
  fi

  if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
    err "SHA-256 mismatch for $(basename "$FILE")!"
    err "  Expected: $EXPECTED_SHA"
    err "  Actual:   $ACTUAL_SHA"
    return 1
  fi
}

install_from_source() {
  APP="$1"
  if ! command -v cargo >/dev/null 2>&1; then
    err "Pre-compiled binary unavailable for $TARGET and cargo is missing."
    err "Install Rust via https://rustup.rs or install on a supported platform."
    return 1
  fi

  info "Compiling $APP from source via cargo..."
  REPO_URL="https://github.com/${REPO_OWNER}/${APP}"
  TMP_CARGO_ROOT="${TMP_DIR}/cargo_root_${APP}"
  mkdir -p "$TMP_CARGO_ROOT"
  cargo install --git "$REPO_URL" --root "$TMP_CARGO_ROOT" --quiet --force
  cp "${TMP_CARGO_ROOT}/bin/${APP}" "${DEST_DIR}/${APP}"
  chmod 755 "${DEST_DIR}/${APP}"
  success "Built and installed $APP to $DEST_DIR/$APP"
}

install_app() {
  APP="$1"
  info "Installing $APP..."

  mkdir -p "$DEST_DIR"

  if [ -z "$TARGET" ]; then
    warn "Unsupported pre-compiled target ($OS $ARCH)."
    install_from_source "$APP"
    return $?
  fi

  ASSET="${APP}-${TARGET}.tar.gz"
  BASE_URL="https://github.com/${REPO_OWNER}/${APP}/releases/latest/download"
  ASSET_URL="${BASE_URL}/${ASSET}"
  SHA_URL="${ASSET_URL}.sha256"

  TMP_APP_DIR="${TMP_DIR}/${APP}"
  mkdir -p "$TMP_APP_DIR"
  ARCHIVE="${TMP_APP_DIR}/${ASSET}"
  SHA_FILE="${TMP_APP_DIR}/${ASSET}.sha256"

  DOWNLOAD_OK=1
  download_file "$ASSET_URL" "$ARCHIVE" || DOWNLOAD_OK=0

  if [ "$DOWNLOAD_OK" -eq 1 ] && [ -s "$ARCHIVE" ]; then
    if download_file "$SHA_URL" "$SHA_FILE" 2>/dev/null && [ -s "$SHA_FILE" ]; then
      EXPECTED_SHA="$(awk '{print $1}' "$SHA_FILE")"
      verify_checksum "$ARCHIVE" "$EXPECTED_SHA"
    fi

    tar -xzf "$ARCHIVE" -C "$TMP_APP_DIR"
    if [ -f "${TMP_APP_DIR}/${APP}" ]; then
      cp "${TMP_APP_DIR}/${APP}" "${DEST_DIR}/${APP}"
      chmod 755 "${DEST_DIR}/${APP}"
      success "Installed $APP to ${DEST_DIR}/${APP}"
      return 0
    fi
  fi

  # Fallback to source compilation
  warn "Pre-built release not found at $ASSET_URL."
  install_from_source "$APP"
}

# Main execution
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'studio2201-install')"
detect_target

TARGET_APPS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dest)
      shift
      DEST_DIR="$1"
      ;;
    -h|--help)
      usage
      ;;
    -V|--version)
      echo "studio2201 installer v0.4.3"
      exit 0
      ;;
    all)
      TARGET_APPS="$ALL_APPS"
      ;;
    vigil|snip|boneyard|aegis|proven)
      TARGET_APPS="${TARGET_APPS}${TARGET_APPS:+ }$1"
      ;;
    *)
      err "Unknown option or application: $1"
      echo ""
      usage
      ;;
  esac
  shift
done

if [ -z "$TARGET_APPS" ]; then
  usage
fi

printf "${BOLD}studio2201 universal installer${RESET}\n"
printf "Target platform: ${CYAN}%s${RESET}\n" "${TARGET:-unknown}"
printf "Destination:     ${CYAN}%s${RESET}\n\n" "$DEST_DIR"

for app in $TARGET_APPS; do
  install_app "$app"
done

printf "\n"
success "Installation process complete."

# Check if DEST_DIR is in PATH
case ":$PATH:" in
  *":$DEST_DIR:"*) ;;
  *)
    printf "\n"
    warn "$DEST_DIR is not currently in your PATH."
    printf "Add it by running:\n"
    printf "  ${BOLD}export PATH=\"%s:\$PATH\"${RESET}\n" "$DEST_DIR"
    printf "Or add that line to your ~/.bashrc or ~/.zshrc\n\n"
    ;;
esac
