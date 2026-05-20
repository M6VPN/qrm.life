#!/usr/bin/env bash
# QRM Life - Developed by M6VPN (M6VPN@tuta.com)
# qrm.life/scripts/bootstrap-server.sh

set -euo pipefail

SITE_DIR="/srv/qrm.life"
PUBLIC_DIR="${SITE_DIR}/public"
DEPLOY_USER="${DEPLOY_USER:-qrmdeploy}"
DEPLOY_GROUP="${DEPLOY_GROUP:-qrmdeploy}"

if [ "$(id -u)" -ne 0 ]; then
	echo "error: run this script as root on voyager"
	exit 1
fi

apt update
apt install -y caddy git rsync hugo python3 python3-venv python3-pip ufw

if ! getent group "${DEPLOY_GROUP}" >/dev/null; then
	groupadd --system "${DEPLOY_GROUP}"
fi

if ! id "${DEPLOY_USER}" >/dev/null 2>&1; then
	useradd --system --gid "${DEPLOY_GROUP}" --home-dir "${SITE_DIR}" --shell /usr/sbin/nologin "${DEPLOY_USER}"
fi

mkdir -p "${PUBLIC_DIR}"
chown -R "${DEPLOY_USER}:${DEPLOY_GROUP}" "${SITE_DIR}"
chmod 755 "${SITE_DIR}" "${PUBLIC_DIR}"

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

systemctl enable caddy
systemctl restart caddy

echo "bootstrap complete for voyager"
