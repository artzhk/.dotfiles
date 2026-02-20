FROM archlinux:base

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
WORKDIR /work

COPY ./pacman-explicit.txt /work/
COPY ./build.sh /work/

RUN pacman -Syu --noconfirm --needed \
	    && xargs -a /work/pacman-explicit.txt pacman -S --noconfirm --needed \
	    && chmod +x /work/build.sh \
	    && /work/build.sh \
	    && rm -rf /var/cache/pacman/pkg/*
