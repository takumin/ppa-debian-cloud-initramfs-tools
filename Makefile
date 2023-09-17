RELEASE_VERSION := 0.18

.PHONY: all
all: repository

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
package-debian10: extract-debian10
	@cd build/debian10/source && dch --nmu --distribution buster ""
	@cd build/debian10/source && dpkg-buildpackage -us -uc
package-debian11: extract-debian11
	@cd build/debian11/source && dch --nmu --distribution bullseye ""
	@cd build/debian11/source && dpkg-buildpackage -us -uc

.PHONY: repository
repository: package
	@mkdir -p public/dists/buster/main/binary-all
	@mkdir -p public/dists/buster/main/source
	@mkdir -p public/dists/bullseye/main/binary-all
	@mkdir -p public/dists/bullseye/main/source
	@mkdir -p public/pool/buster/main
	@mkdir -p public/pool/bullseye/main
	@cp build/debian10/*.dsc public/pool/buster/main/
	@cp build/debian10/*.tar.xz public/pool/buster/main/
	@cp build/debian10/*.deb public/pool/buster/main/
	@cp build/debian11/*.dsc public/pool/bullseye/main/
	@cp build/debian11/*.tar.xz public/pool/bullseye/main/
	@cp build/debian11/*.deb public/pool/bullseye/main/
	@cd public && apt-ftparchive generate ../config/debian10-repos.conf
	@cd public && apt-ftparchive generate ../config/debian11-repos.conf
	@cd public && apt-ftparchive -c ../config/debian10-meta.conf release dists/buster > dists/buster/Release
	@cd public && apt-ftparchive -c ../config/debian11-meta.conf release dists/bullseye > dists/bullseye/Release
	@gpg --clearsign -o public/dists/buster/InRelease public/dists/buster/Release
	@gpg --clearsign -o public/dists/bullseye/InRelease public/dists/bullseye/Release
	@gpg -abs -o public/dists/buster/Release.gpg public/dists/buster/Release
	@gpg -abs -o public/dists/bullseye/Release.gpg public/dists/bullseye/Release

.PHONY: clean
clean:
	@rm -fr build
	@rm -fr public

.PHONY: deepclean
deepclean:
	@rm -fr cache
