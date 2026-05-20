#!/usr/bin/env bash
# QRM Life - Developed by M6VPN (M6VPN@tuta.com)
# qrm.life/scripts/verify.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_INDEX="/srv/qrm.life/public/index.html"

echo "dns: qrm.life and www.qrm.life should both point to 104.244.73.226"

caddy validate --config "${ROOT_DIR}/Caddyfile"

if [ ! -f "${PUBLIC_INDEX}" ]; then
	echo "error: missing ${PUBLIC_INDEX}"
	exit 1
fi

curl -sI --max-time 10 http://127.0.0.1:80 >/dev/null
curl -sI --max-time 10 https://127.0.0.1:443 --insecure >/dev/null

curl -I http://qrm.life
curl -I https://www.qrm.life
curl -I https://qrm.life
