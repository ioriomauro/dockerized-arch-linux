FROM ioriomauro/arch-base:latest

LABEL maintainer="Mauro Iorio <iorio.mauro@gmail.com>"

ADD data/pacman.d/*.conf /tmp/pacman.d/
RUN cat /tmp/pacman.d/*.conf >>/etc/pacman.conf

RUN set -x -- && \
    pacman -Syu --noconfirm && \
    pacman -S --noconfirm --needed sudo base-devel lib32-gcc-libs && \
    sed -e 's/#MAKEFLAGS="-j2"/MAKEFLAGS=-j$(nproc)/g' -i /etc/makepkg.conf && \
    useradd -m -G wheel -s /bin/bash developer

# Some cleanup
RUN set -x -- && \
    pacman -Rs --noconfirm systemd && \
    yes | pacman -Scc

ADD data/sudoers.d/ /etc/sudoers.d/

RUN set -ux -- && \
    echo -e "Arch Linux Development\nBuild time: $(LANG=en_US date -u)" >/RELEASE

USER developer
