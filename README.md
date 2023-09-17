# ppa-debian-cloud-initramfs-tools
Debian Personal Package Archive for cloud-initramfs-tools

# Motivation
Although the overlayroot present in Ubuntu helps protect RootFS, it is not possible to install the overlayroot package from the official Apt repository in Debian 10 and Debian 11.
Fortunately, however, the cloud-initramfs-tools maintainer team has released packages for Debian 10 and Debian 11 that include overlayroot.
This PPA repository is intended to use the work of the cloud-initramfs-tools maintainer team and redistribute the overlayroot package.

# Required
```console
$ sudo apt install build-essential devscripts debhelper quilt
```

# Reference
- Upstream Repository
  - https://github.com/chesty/overlayroot
- Debian Maintainer Team
  - https://salsa.debian.org/cloud-team/cloud-initramfs-tools
