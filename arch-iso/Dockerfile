FROM alpine:latest as builder

RUN apk --no-cache add curl

ARG MIRROR="https://mirror.f4st.host/archlinux"
ARG ISO_VER

RUN mkdir /opt && \
    cd /opt && \
    curl -LO "${MIRROR}/iso/${ISO_VER}/archlinux-bootstrap-${ISO_VER}-x86_64.tar.gz" && \
    curl -L "${MIRROR}/iso/${ISO_VER}/sha1sums.txt" | grep ".tar.gz" > sha1sums.txt && \
    sha1sum -c sha1sums.txt && \
    tar xf "archlinux-bootstrap-${ISO_VER}-x86_64.tar.gz"



FROM scratch

LABEL maintainer="Mauro Iorio <iorio.mauro@gmail.com>"

COPY --from=builder /opt/root.x86_64/ /

ARG MIRROR="https://mirror.f4st.host/archlinux"
ARG ISO_VER

RUN set -x -- && \
    ln -nfs /usr/share/zoneinfo/UTC /etc/localtime && \
    echo "en_US.UTF-8 UTF-8" >/etc/locale.gen && \
    echo "LANG=en_US.UTF-8" >/etc/locale.conf && \
    pacman-key --init && \
    pacman-key --populate archlinux && \
    echo "Server = ${MIRROR}/\$repo/os/\$arch" >/etc/pacman.d/mirrorlist && \
    pacman --noconfirm -Syy && \
    pacman --noconfirm -S --needed sed gzip && \
    locale-gen && \
    echo -e "Arch Linux ${ISO_VER}\nBuild time: $(LANG=en_US date -u)" > /RELEASE

# Some cleanup
RUN pacman --noconfirm -Rs systemd && \
    yes | pacman -Scc

ADD entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/usr/bin/bash", "-l"]