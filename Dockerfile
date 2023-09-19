FROM docker.io/library/debian:10-slim AS debian10

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
        build-essential \
        devscripts \
        debhelper \
        quilt \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ARG DEBFULLNAME
ENV DEBFULLNAME "Takumi Takahashi"

ARG DEBEMAIL
ENV DEBEMAIL "takumiiinn@gmail.com"

WORKDIR build/debian10/source

FROM docker.io/library/debian:11-slim AS debian11

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
        build-essential \
        devscripts \
        debhelper \
        quilt \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ARG DEBFULLNAME
ENV DEBFULLNAME "Takumi Takahashi"

ARG DEBEMAIL
ENV DEBEMAIL "takumiiinn@gmail.com"

WORKDIR build/debian11/source
