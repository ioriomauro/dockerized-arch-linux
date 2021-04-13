FROM scratch

LABEL maintainer="Mauro Iorio <iorio.mauro@gmail.com>"

ADD dist/arch-strap.tar /

RUN set -x -- && \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman --noconfirm -Syy

# Caveat: systemd and it's dependencies actually creates system groups and
# users. This step is needed if You plan to use system groups (e.g.: wheel).
# Systemd is not needed for any other reasons (so far) in a docker image (nor
# in a chroot enviromnent) and then can be removed.
#RUN set -x -- && \
#    pacman --noconfirm -S systemd && \
#    pacman --noconfirm -Rs systemd

# Some cleanup
RUN yes | pacman -Scc

ADD changelog.txt /CHANGELOG
ADD entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/usr/bin/bash", "-l"]
