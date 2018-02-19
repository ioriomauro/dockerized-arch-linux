FROM ioriomauro/arch-base:latest

LABEL maintainer="Mauro Iorio <iorio.mauro@gmail.com>"

ADD data/pacman.d/*.conf /tmp/pacman.d/
RUN cat /tmp/pacman.d/*.conf >>/etc/pacman.conf

RUN pacman -Syu --noconfirm; \
    pacman -S --noconfirm --needed sudo base-devel lib32-gcc-libs; \
    sed -e 's/#MAKEFLAGS="-j2"/MAKEFLAGS=-j$(nproc)/g' -i /etc/makepkg.conf; \
    useradd -m -G wheel -s /bin/bash developer
      
ADD data/sudoers.d/ /etc/sudoers.d/
