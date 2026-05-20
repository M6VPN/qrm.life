#!/usr/bin/env bash
# QRM Life - Developed by M6VPN (M6VPN@tuta.com)
# qrm.life/scripts/build.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="${ROOT_DIR}/.bin"
VENV_DIR="${ROOT_DIR}/.venv"
MKDOCS_OUT="${ROOT_DIR}/.mkdocs-build"
HUGO_STATIC_DOCS="${ROOT_DIR}/site/static/docs"
PUBLIC_DIR="${ROOT_DIR}/public"
HUGO_VERSION="0.126.3"

cd "${ROOT_DIR}"

get_hugo() {
	if command -v hugo >/dev/null 2>&1; then
		command -v hugo
		return
	fi

	local arch
	local archive
	local os
	local url

	os="$(uname -s)"
	arch="$(uname -m)"

	case "${os}:${arch}" in
		Linux:x86_64)
			archive="hugo_${HUGO_VERSION}_Linux-64bit.tar.gz"
			;;
		Linux:aarch64)
			archive="hugo_${HUGO_VERSION}_Linux-ARM64.tar.gz"
			;;
		*)
			echo "error: install hugo or add support for ${os}:${arch}" >&2
			exit 1
			;;
	esac

	mkdir -p "${BIN_DIR}/hugo"
	url="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${archive}"

	if [ ! -x "${BIN_DIR}/hugo/hugo" ]; then
		curl -fsSL "${url}" | tar -xz -C "${BIN_DIR}/hugo" hugo
	fi

	echo "${BIN_DIR}/hugo/hugo"
}

HUGO_BIN="$(get_hugo)"

if [ ! -d "${VENV_DIR}" ]; then
	python3 -m venv "${VENV_DIR}"
fi

"${VENV_DIR}/bin/python" -m pip install --upgrade pip >/dev/null
"${VENV_DIR}/bin/python" -m pip install --upgrade mkdocs >/dev/null

rm -rf "${MKDOCS_OUT}" "${HUGO_STATIC_DOCS}" "${PUBLIC_DIR}"
mkdir -p "${HUGO_STATIC_DOCS}"

"${VENV_DIR}/bin/mkdocs" build --config-file "${ROOT_DIR}/docs/mkdocs.yml" --clean
cp -a "${MKDOCS_OUT}/." "${HUGO_STATIC_DOCS}/"

"${HUGO_BIN}" --source "${ROOT_DIR}/site" --destination "${PUBLIC_DIR}" --cleanDestinationDir
