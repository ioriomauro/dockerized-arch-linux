FROM scratch

LABEL maintainer="Mauro Iorio <iorio.mauro@gmail.com>"

ADD dist/arch-strap.tar /

RUN set -x -- && \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman --noconfirm -Syy

# Some cleanup
RUN yes | pacman -Scc

ADD entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/usr/bin/bash", "-l"]
