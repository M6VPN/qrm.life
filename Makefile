# QRM Life - Developed by M6VPN (M6VPN@tuta.com)
# qrm.life/Makefile

.PHONY: build clean deploy serve verify

build:
	./scripts/build.sh

clean:
	rm -rf public .mkdocs-build site/static/docs site/public site/resources

deploy:
	./scripts/deploy.sh

serve: build
	cd site && hugo server --bind 127.0.0.1 --baseURL http://127.0.0.1:1313/

verify:
	./scripts/verify.sh
