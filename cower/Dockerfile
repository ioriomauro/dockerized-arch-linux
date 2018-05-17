FROM ioriomauro/arch-devel:latest

LABEL maintainer="Mauro Iorio <iorio.mauro@gmail.com>"

RUN set -ux -- && \
    /usr/bin/gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53 && \
    mkdir /home/developer/cower && \
    cd /home/developer/cower && \
    curl -o PKGBUILD 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower' && \
    makepkg -s --noconfirm

RUN sudo pacman -U --noconfirm /home/developer/cower/*.pkg.tar.xz

RUN rm -rf /home/developer/cower

ADD ./data/entrypoint.sh /

VOLUME /packages

ENTRYPOINT [ "/entrypoint.sh" ]
