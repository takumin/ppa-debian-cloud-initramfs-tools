RELEASE_VERSION := 0.18

.PHONY: all
all: builder download extract package

.PHONY: builder
builder: builder-debian10 builder-debian11
builder-debian10:
	@nerdctl build --target debian10-builder --tag takumi/overlayroot-debian10-builder:latest .
builder-debian11:
	@nerdctl build --target debian11-builder --tag takumi/overlayroot-debian11-builder:latest .

.PHONY: download
download: download-debian10 download-debian11
download-debian10:
	@test -f "debian10.tar.gz" || wget -O "debian10.tar.gz" "https://salsa.debian.org/cloud-team/cloud-initramfs-tools/-/archive/debian/${RELEASE_VERSION}.debian10/cloud-initramfs-tools-debian-${RELEASE_VERSION}.debian10.tar.gz"
download-debian11:
	@test -f "debian11.tar.gz" || wget -O "debian11.tar.gz" "https://salsa.debian.org/cloud-team/cloud-initramfs-tools/-/archive/debian/${RELEASE_VERSION}.debian11/cloud-initramfs-tools-debian-${RELEASE_VERSION}.debian11.tar.gz"

.PHONY: extract
extract: extract-debian10 extract-debian11
extract-debian10: download-debian10
	@if [ ! -d "debian10" ]; then \
		mkdir "debian10"; \
		tar -xvf "debian10.tar.gz" -C "debian10" --strip-components=1; \
	fi
extract-debian11: download-debian11
	@if [ ! -d "debian11" ]; then \
		mkdir "debian11"; \
		tar -xvf "debian11.tar.gz" -C "debian11" --strip-components=1; \
	fi

.PHONY: package
package: package-debian10 package-debian11
package-debian10: extract-debian10
	@nerdctl run --rm -i -t -v "$(CURDIR):/build" takumi/overlayroot-debian10-builder:latest dpkg-buildpackage -us -uc
package-debian11: extract-debian11
	@nerdctl run --rm -i -t -v "$(CURDIR):/build" takumi/overlayroot-debian11-builder:latest dpkg-buildpackage -us -uc

.PHONY: clean
clean:
	@nerdctl system prune -f
	@rm -fr debian10
	@rm -fr debian11
	@rm -fr *.buildinfo
	@rm -fr *.changes
	@rm -fr *.deb
	@rm -fr *.dsc

.PHONY: deepclean
deepclean:
	@rm -f *.tar.gz
	@rm -f *.tar.xz
