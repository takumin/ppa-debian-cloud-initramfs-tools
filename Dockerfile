FROM debian:10-slim AS debian10-builder

RUN apt-get update \
 && apt-get install --no-install-recommends -y build-essential dpkg-dev debhelper quilt \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build/debian10

FROM debian:11-slim AS debian11-builder

RUN apt-get update \
 && apt-get install --no-install-recommends -y build-essential dpkg-dev debhelper quilt \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build/debian11
