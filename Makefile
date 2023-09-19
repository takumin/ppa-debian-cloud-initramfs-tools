RELEASE_VERSION := 0.18

DEBFULLNAME ?= Takumi Takahashi
DEBEMAIL    ?= takumiiinn@gmail.com

DOCKER_IMAGE      ?= takumi/ppa-cloud-initramfs-tools
DOCKER_BUILD_ARGS ?= --build-arg "DEBFULLNAME=$(DEBFULLNAME)" --build-arg "DEBEMAIL=$(DEBEMAIL)"

.PHONY: all
all: assets

.PHONY: builder
builder:
	@docker build $(DOCKER_BUILD_ARGS) --target debian10 --tag $(DOCKER_IMAGE):debian10 .
	@docker build $(DOCKER_BUILD_ARGS) --target debian11 --tag $(DOCKER_IMAGE):debian11 .

.PHONY: download
download: download-debian10 download-debian11
dowload-directory:
	@mkdir -p "cache"
download-debian10: dowload-directory
	@test -f "cache/debian10.tar.gz" || wget -O "cache/debian10.tar.gz" "https://salsa.debian.org/cloud-team/cloud-initramfs-tools/-/archive/debian/${RELEASE_VERSION}.debian10/cloud-initramfs-tools-debian-${RELEASE_VERSION}.debian10.tar.gz"
download-debian11: dowload-directory
	@test -f "cache/debian11.tar.gz" || wget -O "cache/debian11.tar.gz" "https://salsa.debian.org/cloud-team/cloud-initramfs-tools/-/archive/debian/${RELEASE_VERSION}.debian11/cloud-initramfs-tools-debian-${RELEASE_VERSION}.debian11.tar.gz"

.PHONY: extract
extract: extract-debian10 extract-debian11
extract-debian10: download-debian10
	@if [ ! -d "build/debian10/source" ]; then \
		mkdir -p "build/debian10/source"; \
		tar -xvf "cache/debian10.tar.gz" -C "build/debian10/source" --strip-components=1; \
	fi
extract-debian11: download-debian11
	@if [ ! -d "build/debian11/source" ]; then \
		mkdir -p "build/debian11/source"; \
		tar -xvf "cache/debian11.tar.gz" -C "build/debian11/source" --strip-components=1; \
	fi

.PHONY: package
package: package-debian10 package-debian11
package-debian10: builder extract-debian10
	@docker run --rm -v "$(CURDIR)/build/debian10:/build/debian10" $(DOCKER_IMAGE):debian10 dch --nmu --distribution buster ""
	@docker run --rm -v "$(CURDIR)/build/debian10:/build/debian10" $(DOCKER_IMAGE):debian10 dpkg-buildpackage -us -uc
package-debian11: builder extract-debian11
	@docker run --rm -v "$(CURDIR)/build/debian11:/build/debian11" $(DOCKER_IMAGE):debian11 dch --nmu --distribution bullseye ""
	@docker run --rm -v "$(CURDIR)/build/debian11:/build/debian11" $(DOCKER_IMAGE):debian11 dpkg-buildpackage -us -uc

.PHONY: repository
repository: package
	@mkdir -p public/dists/buster/main/binary-all
	@mkdir -p public/dists/buster/main/binary-i386
	@mkdir -p public/dists/buster/main/binary-amd64
	@mkdir -p public/dists/buster/main/binary-armhf
	@mkdir -p public/dists/buster/main/binary-arm64
	@mkdir -p public/dists/buster/main/source
	@mkdir -p public/dists/bullseye/main/binary-all
	@mkdir -p public/dists/bullseye/main/binary-i386
	@mkdir -p public/dists/bullseye/main/binary-amd64
	@mkdir -p public/dists/bullseye/main/binary-armhf
	@mkdir -p public/dists/bullseye/main/binary-arm64
	@mkdir -p public/dists/bullseye/main/source
	@mkdir -p public/pool/buster/main
	@mkdir -p public/pool/bullseye/main
	@cp build/debian10/*.dsc public/pool/buster/main/
	@cp build/debian10/*.tar.xz public/pool/buster/main/
	@cp build/debian10/*.deb public/pool/buster/main/
	@cp build/debian11/*.dsc public/pool/bullseye/main/
	@cp build/debian11/*.tar.xz public/pool/bullseye/main/
	@cp build/debian11/*.deb public/pool/bullseye/main/
	@cd public && apt-ftparchive generate ../assets/debian10-repos.conf
	@cd public && apt-ftparchive generate ../assets/debian11-repos.conf
	@cd public && apt-ftparchive -c ../assets/debian10-meta.conf release dists/buster > dists/buster/Release
	@cd public && apt-ftparchive -c ../assets/debian11-meta.conf release dists/bullseye > dists/bullseye/Release

.PHONY: reposign
reposign: repository
	@gpg --homedir secret/gpghome \
		--pinentry-mode loopback \
		--passphrase "$$(cat secret/passphrase)" \
		--clearsign \
		-o public/dists/buster/InRelease \
		public/dists/buster/Release
	@gpg --homedir secret/gpghome \
		--pinentry-mode loopback \
		--passphrase "$$(cat secret/passphrase)" \
		--clearsign \
		-o public/dists/bullseye/InRelease \
		public/dists/bullseye/Release
	@gpg --homedir secret/gpghome \
		--pinentry-mode loopback \
		--passphrase "$$(cat secret/passphrase)" \
		-abs \
		-o public/dists/buster/Release.gpg \
		public/dists/buster/Release
	@gpg --homedir secret/gpghome \
		--pinentry-mode loopback \
		--passphrase "$$(cat secret/passphrase)" \
		-abs \
		-o public/dists/bullseye/Release.gpg \
		public/dists/bullseye/Release

.PHONY: assets
assets: reposign
	@cp assets/index.html public/index.html
	@cp assets/public.gpg.asc public/public.gpg.asc
	@echo 'deb [signed-by=/etc/apt/keyrings/ppa-debian-cloud-initramfs-tools.asc] https://takumi.tmfam.com/ppa-debian-cloud-initramfs-tools buster main' > public/buster.source.list
	@echo 'deb-src [signed-by=/etc/apt/keyrings/ppa-debian-cloud-initramfs-tools.asc] https://takumi.tmfam.com/ppa-debian-cloud-initramfs-tools buster main' >> public/buster.source.list
	@echo 'deb [signed-by=/etc/apt/keyrings/ppa-debian-cloud-initramfs-tools.asc] https://takumi.tmfam.com/ppa-debian-cloud-initramfs-tools bullseye main' > public/bullseye.source.list
	@echo 'deb-src [signed-by=/etc/apt/keyrings/ppa-debian-cloud-initramfs-tools.asc] https://takumi.tmfam.com/ppa-debian-cloud-initramfs-tools bullseye main' >> public/bullseye.source.list

.PHONY: gengpg
gengpg: assets/public.gpg.asc secret/secret.gpg.asc
secret/passphrase:
	@mkdir -p -m 0700 secret
	@pwgen -ncys1 64 > secret/passphrase
	@chmod 0600 secret/passphrase
secret/gpghome: secret/passphrase
	@mkdir -p -m 0700 secret/gpghome
	@gpg --homedir secret/gpghome \
		--pinentry-mode loopback \
		--passphrase "$$(cat secret/passphrase)" \
		--quick-generate-key "$(DEBFULLNAME) <$(DEBEMAIL)>" \
		default default 10y
assets/public.gpg.asc: secret/gpghome
	@gpg --homedir secret/gpghome \
		--export --armor \
		--output assets/public.gpg.asc \
		--yes \
		"$(DEBFULLNAME) <$(DEBEMAIL)>"
secret/secret.gpg.asc: secret/gpghome secret/passphrase
	@gpg --homedir secret/gpghome \
		--pinentry-mode loopback \
		--passphrase "$$(cat secret/passphrase)" \
		--export-secret-keys --armor \
		--output secret/secret.gpg.asc \
		--yes \
		"$(DEBFULLNAME) <$(DEBEMAIL)>"

.PHONY: clean
clean:
	@docker system prune -f
	@sudo rm -fr build
	@rm -fr public

.PHONY: deepclean
deepclean:
	@rm -fr cache
	@rm -fr secret
