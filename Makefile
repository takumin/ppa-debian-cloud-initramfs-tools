RELEASE_VERSION := 0.18

.PHONY: all
all: download extract

.PHONY: download
download: debian10.tar.gz debian11.tar.gz
debian10.tar.gz:
	@test -f "debian10.tar.gz" || wget -O "debian10.tar.gz" "https://salsa.debian.org/cloud-team/cloud-initramfs-tools/-/archive/debian/${RELEASE_VERSION}.debian10/cloud-initramfs-tools-debian-${RELEASE_VERSION}.debian10.tar.gz"
debian11.tar.gz:
	@test -f "debian11.tar.gz" || wget -O "debian11.tar.gz" "https://salsa.debian.org/cloud-team/cloud-initramfs-tools/-/archive/debian/${RELEASE_VERSION}.debian11/cloud-initramfs-tools-debian-${RELEASE_VERSION}.debian11.tar.gz"

.PHONY: extract
extract: debian10 debian11
debian10:
	@if [ ! -d "debian10" ]; then \
		mkdir "debian10"; \
		tar -xvf "debian10.tar.gz" -C "debian10" --strip-components=1; \
	fi
debian11:
	@if [ ! -d "debian11" ]; then \
		mkdir "debian11"; \
		tar -xvf "debian11.tar.gz" -C "debian11" --strip-components=1; \
	fi

.PHONY: clean
clean:
	@rm -fr debian10
	@rm -fr debian11

.PHONY: deepclean
deepclean:
	@rm -f *.tar.gz
