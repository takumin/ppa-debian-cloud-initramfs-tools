RELEASE_VERSION := 0.18

.PHONY: all
all: repository

.PHONY: download
download: download-debian10 download-debian11
download-debian10:
	@test -f "debian10.tar.gz" || wget -O "debian10.tar.gz" "https://salsa.debian.org/cloud-team/cloud-initramfs-tools/-/archive/debian/${RELEASE_VERSION}.debian10/cloud-initramfs-tools-debian-${RELEASE_VERSION}.debian10.tar.gz"
download-debian11:
	@test -f "debian11.tar.gz" || wget -O "debian11.tar.gz" "https://salsa.debian.org/cloud-team/cloud-initramfs-tools/-/archive/debian/${RELEASE_VERSION}.debian11/cloud-initramfs-tools-debian-${RELEASE_VERSION}.debian11.tar.gz"

.PHONY: extract
extract: extract-debian10 extract-debian11
extract-debian10: download-debian10
	@if [ ! -d "build/debian10/source" ]; then \
		mkdir -p "build/debian10/source"; \
		tar -xvf "debian10.tar.gz" -C "build/debian10/source" --strip-components=1; \
	fi
extract-debian11: download-debian11
	@if [ ! -d "build/debian11/source" ]; then \
		mkdir -p "build/debian11/source"; \
		tar -xvf "debian11.tar.gz" -C "build/debian11/source" --strip-components=1; \
	fi

.PHONY: package
package: package-debian10 package-debian11
package-debian10: extract-debian10
	@cd build/debian10/source && dpkg-buildpackage -us -uc
package-debian11: extract-debian11
	@cd build/debian11/source && dpkg-buildpackage -us -uc

.PHONY: repository
repository: package
	@mkdir -p public
	@cp ./build/debian10/overlayroot_* public/
	@cp ./build/debian11/overlayroot_* public/
	@dpkg-scanpackages --multiversion public > public/Packages
	@gzip -k -f public/Packages
	@apt-ftparchive release public > public/Release

.PHONY: clean
clean:
	@rm -fr build
	@rm -fr public

.PHONY: deepclean
deepclean:
	@rm -f *.tar.gz
