#!/usr/bin/env bash
# QRM Life - Developed by M6VPN (M6VPN@tuta.com)
# qrm.life/scripts/install-caddyfile.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

caddy validate --config "${ROOT_DIR}/Caddyfile"
install -m 644 "${ROOT_DIR}/Caddyfile" /etc/caddy/Caddyfile
systemctl reload caddy
