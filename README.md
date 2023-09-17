# ppa-debian-overlayroot
Debian Personal Package Archive for overlayroot

# Motivation
Although the overlayroot present in Ubuntu helps protect RootFS, it is not possible to install the overlayroot package from the official Apt repository in Debian 10 and Debian 11.
Fortunately, however, the cloud-initramfs-tools maintainer team has released a package that includes overlayroot for Debian 10 and Debian 11.
This PPA repository aims to use the cloud-initramfs-tools maintainer team's deliverables and redistribute only the overlayroot package.

# Required
```console
$ sudo apt install build-essential dpkg-dev debhelper quilt
```

# Reference
- Upstream Repository
  - https://github.com/chesty/overlayroot
- Debian Maintainer Team
  - https://salsa.debian.org/cloud-team/cloud-initramfs-tools
