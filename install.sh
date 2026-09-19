#!/bin/sh
# studio2201 universal installer
# Installs & updates studio2201 tools (vigil, snip, boneyard, aegis, proven)
# Zero root required · Linux XDG compliance (${XDG_BIN_HOME:-$HOME/.local/bin})
set -e

REPO_OWNER="${REPO_OWNER:-studio2201}"
RELEASE_BASE="${RELEASE_BASE:-https://github.com/${REPO_OWNER}}"
UPDATE_BASE="${UPDATE_BASE:-https://studio2201.com}"
DEFAULT_DEST="${XDG_BIN_HOME:-$HOME/.local/bin}"
DEST_DIR="${INSTALL_DIR:-$DEFAULT_DEST}"
ALL_APPS="vigil snip boneyard aegis proven cli"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD="\033[1m" GREEN="\033[32m" YELLOW="\033[33m"
  RED="\033[31m" CYAN="\033[36m" RESET="\033[0m"
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
  install.sh [OPTIONS] [COMMAND] [APP | all]

Commands:
  install   Install application(s) [default]
  update    Update application(s) to latest release (alias: upgrade)

Applications:
  vigil (dormancy)  snip (diff gate)    boneyard (tech-debt)
  aegis (PQC SDK)   proven (attestor)   cli (studio2201 CLI)
  all (all 6 tools)

Options:
  --dest <DIR>  Install dir (default: \${XDG_BIN_HOME:-\$HOME/.local/bin})
  -h, --help    Show this help message
  -V, --version Show installer version

Examples:
  sh install.sh vigil
  sh install.sh update all
  sh install.sh upgrade snip
  curl -fsSL https://studio2201.com/install.sh | sh -s all
EOF
  exit "${1:-0}"
}

cleanup() { [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

detect_target() {
  OS="$(uname -s 2>/dev/null || true)"
  ARCH="$(uname -m 2>/dev/null || true)"
  case "${OS}-${ARCH}" in
    Linux-x86_64) TARGET="x86_64-unknown-linux-musl" ;;
    Linux-aarch64|Linux-arm64) TARGET="aarch64-unknown-linux-musl" ;;
    Darwin-x86_64) TARGET="x86_64-apple-darwin" ;;
    Darwin-arm64|Darwin-aarch64) TARGET="aarch64-apple-darwin" ;;
    *) TARGET="" ;;
  esac
}

download_file() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --connect-timeout 10 "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget -q --timeout=10 "$1" -O "$2"
  else
    err "Neither curl nor wget found in PATH."; return 1
  fi
}

verify_checksum() {
  ACTUAL="$(sha256sum "$1" 2>/dev/null | awk '{print $1}')"
  [ -z "$ACTUAL" ] && \
    ACTUAL="$(shasum -a 256 "$1" 2>/dev/null | awk '{print $1}')"
  [ -z "$ACTUAL" ] && { warn "Checksum tool missing; skipping."; return 0; }
  [ "$ACTUAL" = "$2" ] || { err "SHA mismatch ($ACTUAL != $2)"; return 1; }
}

resolve_app() {
  case "$1" in
    cli|studio2201) APP_REPO="cli"; APP_BIN="studio2201" ;;
    *) APP_REPO="$1"; APP_BIN="$1" ;;
  esac
}

install_from_source() {
  resolve_app "$1"
  command -v cargo >/dev/null 2>&1 || \
    { err "Pre-compiled binary unavailable and cargo missing."; return 1; }
  info "Compiling $APP_BIN from source via cargo..."
  TMP_ROOT="${TMP_DIR}/cargo_${APP_REPO}"
  mkdir -p "$TMP_ROOT"
  cargo install --git "${RELEASE_BASE}/${APP_REPO}" \
    --root "$TMP_ROOT" --quiet --force
  cp "${TMP_ROOT}/bin/${APP_BIN}" "${DEST_DIR}/${APP_BIN}"
  chmod 755 "${DEST_DIR}/${APP_BIN}"
  success "Built and installed $APP_BIN to ${DEST_DIR}/${APP_BIN}"
}

install_app() {
  resolve_app "$1"
  info "Installing $APP_BIN..."
  mkdir -p "$DEST_DIR"
  [ -z "$TARGET" ] && { install_from_source "$1"; return $?; }
  ASSET="${APP_BIN}-${TARGET}.tar.gz"
  ASSET_URL="${RELEASE_BASE}/${APP_REPO}/releases/latest/download/${ASSET}"
  TMP_APP_DIR="${TMP_DIR}/${APP_REPO}"
  mkdir -p "$TMP_APP_DIR"
  ARCHIVE="${TMP_APP_DIR}/${ASSET}"
  SHA_FILE="${TMP_APP_DIR}/${ASSET}.sha256"

  if download_file "$ASSET_URL" "$ARCHIVE" && [ -s "$ARCHIVE" ]; then
    if download_file "${ASSET_URL}.sha256" "$SHA_FILE" 2>/dev/null && \
       [ -s "$SHA_FILE" ]; then
      verify_checksum "$ARCHIVE" "$(awk '{print $1}' "$SHA_FILE")"
    fi
    tar -xzf "$ARCHIVE" -C "$TMP_APP_DIR"
    if [ -f "${TMP_APP_DIR}/${APP_BIN}" ]; then
      cp "${TMP_APP_DIR}/${APP_BIN}" "${DEST_DIR}/${APP_BIN}"
      chmod 755 "${DEST_DIR}/${APP_BIN}"
      success "Installed $APP_BIN to ${DEST_DIR}/${APP_BIN}"
      return 0
    fi
  fi
  warn "Pre-built release not found at $ASSET_URL."
  install_from_source "$1"
}

get_latest_version() {
  resolve_app "$1"
  LATEST=""
  URL="${RELEASE_BASE}/${APP_REPO}/releases/latest"
  if command -v curl >/dev/null 2>&1; then
    LATEST="$(curl -sI --max-time 5 "$URL" 2>/dev/null | \
      grep -i "^location:" | sed -E 's/.*tag\/v?//' | tr -d '\r\n ')"
    [ -z "$LATEST" ] && LATEST="$(curl -fsSL --max-time 5 \
      "${UPDATE_BASE}/VERSION" 2>/dev/null | tr -d '\r\n ')"
  elif command -v wget >/dev/null 2>&1; then
    LATEST="$(wget --spider -S --timeout=5 "$URL" 2>&1 | \
      grep -i "Location:" | sed -E 's/.*tag\/v?//' | tr -d '\r\n ')"
    [ -z "$LATEST" ] && LATEST="$(wget -qO- --timeout=5 \
      "${UPDATE_BASE}/VERSION" 2>/dev/null | tr -d '\r\n ')"
  fi
  echo "$LATEST"
}

get_local_version() {
  resolve_app "$1"
  BIN="${DEST_DIR}/$APP_BIN"
  [ -x "$BIN" ] || return 0
  VER="$("$BIN" -V 2>/dev/null | awk '{print $2}' || true)"
  [ -z "$VER" ] && \
    VER="$("$BIN" --version 2>/dev/null | awk '{print $NF}' || true)"
  echo "$VER" | sed 's/^v//' | tr -d '\r\n '
}

update_app() {
  APP="$1"
  CUR="$(get_local_version "$APP")"
  LAT="$(get_latest_version "$APP")"
  if [ -n "$LAT" ] && [ -n "$CUR" ] && [ "$CUR" = "$LAT" ]; then
    success "$APP is up to date (v$CUR)."
    return 0
  fi
  if [ -z "$LAT" ] && [ -n "$CUR" ]; then
    warn "Could not check latest release for $APP; keeping v$CUR."
    return 0
  fi
  [ -n "$CUR" ] && info "Updating $APP (v$CUR -> v${LAT:-latest})..."
  [ -z "$CUR" ] && info "Installing $APP (v${LAT:-latest})..."
  install_app "$APP"
}

# Main execution
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'studio2201-install')"
detect_target
ACTION="install"
TARGET_APPS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dest)
      shift; [ -z "${1:-}" ] && { err "--dest missing arg"; usage 2; }
      DEST_DIR="$1" ;;
    -h|--help|help) usage 0 ;;
    -V|--version|version) echo "studio2201 installer v0.4.4"; exit 0 ;;
    install) ACTION="install" ;;
    update|upgrade) ACTION="update" ;;
    all) TARGET_APPS="$ALL_APPS" ;;
    vigil|snip|boneyard|aegis|proven)
      TARGET_APPS="${TARGET_APPS}${TARGET_APPS:+ }$1" ;;
    *) err "Unknown option or application: $1"; echo "" >&2; usage 2 ;;
  esac
  shift
done

if [ -z "$TARGET_APPS" ]; then
  if [ "$ACTION" = "update" ]; then
    for a in $ALL_APPS; do
      [ -x "${DEST_DIR}/${a}" ] && \
        TARGET_APPS="${TARGET_APPS}${TARGET_APPS:+ }$a"
    done
    if [ -z "$TARGET_APPS" ]; then
      info "No installed studio2201 apps found in $DEST_DIR to update."
      exit 0
    fi
  else
    usage 0
  fi
fi

printf "${BOLD}studio2201 universal installer${RESET}\n"
printf "Platform: %s | Dest: %s | Action: %s\n\n" \
  "${TARGET:-unknown}" "$DEST_DIR" "$ACTION"

for app in $TARGET_APPS; do
  if [ "$ACTION" = "update" ]; then
    update_app "$app"
  else
    install_app "$app"
  fi
done

printf "\n"
success "Operation complete."

case ":$PATH:" in
  *":$DEST_DIR:"*) ;;
  *)
    printf "\n"
    warn "$DEST_DIR is not currently in your PATH."
    printf "Add it: export PATH=\"%s:\$PATH\"\n\n" "$DEST_DIR"
    ;;
esac
