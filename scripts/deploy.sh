#!/usr/bin/env bash
# QRM Life - Developed by M6VPN (M6VPN@tuta.com)
# qrm.life/scripts/deploy.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="${DEST_DIR:-/srv/qrm.life/public}"
INSTALL_CADDYFILE="false"

for arg in "$@"; do
	case "${arg}" in
		--install-caddyfile)
			INSTALL_CADDYFILE="true"
			;;
		*)
			echo "error: unknown argument: ${arg}"
			exit 1
			;;
	esac
done

"${ROOT_DIR}/scripts/build.sh"

if [ ! -d "${DEST_DIR}" ]; then
	mkdir -p "${DEST_DIR}"
fi

rsync -a --delete "${ROOT_DIR}/public/" "${DEST_DIR}/"

if id caddy >/dev/null 2>&1; then
	chown -R caddy:caddy "${DEST_DIR}"
else
	chown -R root:root "${DEST_DIR}"
fi

find "${DEST_DIR}" -type d -exec chmod 755 {} \;
find "${DEST_DIR}" -type f -exec chmod 644 {} \;

caddy validate --config "${ROOT_DIR}/Caddyfile"

if [ "${INSTALL_CADDYFILE}" = "true" ]; then
	install -m 644 "${ROOT_DIR}/Caddyfile" /etc/caddy/Caddyfile
fi

systemctl reload caddy
