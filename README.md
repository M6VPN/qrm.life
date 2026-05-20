# QRM.Life

The public static website and deployment repo for `qrm.life`.

The site is my hobby space for electronics, RF, amateur radio notes, schematics, blog posts, media attachments, downloadable files, and future BBS gateway documentation. The first version is static only: Hugo builds the main site, MkDocs builds structured documentation under `/docs/`, and Caddy serves the final output with Let's Encrypt HTTPS.

## Table of Contents

- [DNS](#dns)
- [Requirements](#requirements)
- [Initial Server Setup](#initial-server-setup)
- [Build Locally](#build-locally)
- [Deploy](#deploy)
- [Install Caddyfile](#install-caddyfile)
- [Verify HTTPS](#verify-https)
- [Add Content](#add-content)
- [Future TODOs](#future-todos)

## DNS

| Type | Name           | Value            |
| ---- | -------------- | ---------------- |
| A    | `qrm.life`     | `104.244.73.226` |
| A    | `www.qrm.life` | `104.244.73.226` |

## Requirements

- Debian stable/minimal VPS named `voyager`
- Public IPv4: `104.244.73.226`
- DNS records above pointed at the VPS
- Caddy
- Git
- rsync
- Hugo
- Python 3
- Python venv support
- Python pip
- ufw

If Hugo is not installed locally, `scripts/build.sh` downloads a pinned Hugo binary into `.bin/`.

## Initial Server Setup

```bash
./scripts/bootstrap-server.sh
```

- Installs Caddy, Git, rsync, Hugo, Python 3, venv support, pip, and ufw
- Creates `/srv/qrm.life/public`
- Creates a locked system deploy user and group named `qrmdeploy`
- Opens only TCP ports `22`, `80`, and `443`
- Enables and restarts Caddy

## Build Locally

Build the full static site:

```bash
make build
```

Build output is written to:

```text
public/
```

The build process:

1. Builds MkDocs into `.mkdocs-build/`
2. Copies generated docs into `site/static/docs/`
3. Builds Hugo into `public/`
4. Produces a complete static site with `/docs/`

Preview locally:

```bash
make serve
```

Clean generated files:

```bash
make clean
```

## Deploy

Deploy on `voyager`:

```bash
make deploy
```

This runs `scripts/deploy.sh`, which:

- Builds the site
- Copies `public/` to `/srv/qrm.life/public/`
- Sets directory permissions to `755`
- Sets file permissions to `644`
- Validates `Caddyfile`
- Reloads Caddy

The default deploy path can be changed with:

```bash
DEST_DIR=/srv/qrm.life/public ./scripts/deploy.sh
```

## Install Caddyfile

Validate and install the Caddy config:

```bash
./scripts/deploy.sh --install-caddyfile
```

Or install only the Caddyfile:

```bash
./scripts/install-caddyfile.sh
```

Caddy serves:

```text
/srv/qrm.life/public
```

`www.qrm.life` redirects permanently to:

```text
https://qrm.life{uri}
```

## Verify HTTPS

After DNS is live and Caddy is running:

```bash
make verify
```

The verification script checks:

- DNS reminder for `qrm.life` and `www.qrm.life`
- `caddy validate`
- `/srv/qrm.life/public/index.html`
- Local HTTP and HTTPS reachability
- `http://qrm.life` HTTPS redirect
- `https://www.qrm.life` apex redirect
- `https://qrm.life` 200 response

## Add Content

Main Hugo content lives under:

```text
site/content/
```

Use these sections:

| Section      | Path                       |
| ------------ | -------------------------- |
| Blog         | `site/content/posts/`      |
| Electronics  | `site/content/projects/`   |
| Schematics   | `site/content/schematics/` |
| Packet Radio | `site/content/radio/`      |
| About        | `site/content/about.md`    |

Structured docs live under:

```text
docs/docs/
```

Static files live under:

| File Type   | Path                     |
| ----------- | ------------------------ |
| Attachments | `site/static/files/`     |
| Downloads   | `site/static/downloads/` |
| Images      | `site/static/images/`    |

After building, static files are served from matching public paths.

## Future TODOs

- Tailscale private overlay
- Home LinBPQ access
- VPS-side BBS gateway
- Telnet gateway
- Monitoring
- Backups
