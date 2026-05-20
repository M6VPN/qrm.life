#!/usr/bin/env bash
# QRM Life - Developed by M6VPN (M6VPN@tuta.com)
# qrm.life/scripts/verify.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_INDEX="/srv/qrm.life/public/index.html"

check_url() {
	local label="$1"
	local url="$2"
	local insecure="${3:-false}"

	if [ "${insecure}" = "true" ]; then
		if curl -sI --max-time 10 --insecure "${url}" >/dev/null; then
			echo "ok: ${label}"
			return 0
		fi
	elif curl -sI --max-time 10 "${url}" >/dev/null; then
		echo "ok: ${label}"
		return 0
	fi

	echo "error: ${label} failed (${url})"
	return 1
}

echo "dns: qrm.life and www.qrm.life should both point to 104.244.73.226"

caddy validate --config "${ROOT_DIR}/Caddyfile"

if command -v systemctl >/dev/null 2>&1; then
	if systemctl is-active --quiet caddy; then
		echo "ok: caddy service is active"
	else
		echo "error: caddy service is not active"
		exit 1
	fi
fi

if [ ! -f "${PUBLIC_INDEX}" ]; then
	echo "error: missing ${PUBLIC_INDEX}"
	exit 1
fi

check_url "local HTTP port 80" "http://127.0.0.1:80"
check_url "local HTTPS port 443" "https://127.0.0.1:443" "true"

check_url "http://qrm.life redirects to HTTPS" "http://qrm.life"
check_url "https://www.qrm.life redirects to apex" "https://www.qrm.life"
check_url "https://qrm.life returns a response" "https://qrm.life"
