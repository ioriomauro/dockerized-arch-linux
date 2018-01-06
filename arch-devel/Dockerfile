FROM ioriomauro/arch-base:latest

LABEL maintainer="Mauro Iorio <iorio.mauro@gmail.com>"

RUN pacman -Syu --noconfirm; \
    pacman -S --noconfirm --needed sudo base-devel; \
    sed -e 's/#MAKEFLAGS="-j2"/MAKEFLAGS=-j$(nproc)/g' -i /etc/makepkg.conf; \
    useradd -m -G wheel -s /bin/bash developer
      
ADD data/sudoers.d/ /etc/sudoers.d/
