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
	local resolve="${4:-}"

	if [ "${insecure}" = "true" ]; then
		if [ -n "${resolve}" ]; then
			if curl -sI --max-time 10 --insecure --resolve "${resolve}" "${url}" >/dev/null; then
				echo "ok: ${label}"
				return 0
			fi
		elif curl -sI --max-time 10 --insecure "${url}" >/dev/null; then
			echo "ok: ${label}"
			return 0
		fi
	elif [ -n "${resolve}" ]; then
		if curl -sI --max-time 10 --resolve "${resolve}" "${url}" >/dev/null; then
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

check_port() {
	local host="$1"
	local port="$2"

	if timeout 10 bash -c "</dev/tcp/${host}/${port}" 2>/dev/null; then
		echo "ok: local port ${port} is reachable"
	else
		echo "error: local port ${port} is not reachable"
		return 1
	fi
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

check_port "127.0.0.1" "80"
check_port "127.0.0.1" "443"

check_url "http://qrm.life redirects to HTTPS" "http://qrm.life"
check_url "https://www.qrm.life redirects to apex" "https://www.qrm.life"
check_url "https://qrm.life returns a response" "https://qrm.life"
