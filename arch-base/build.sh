#!/bin/bash
set -uex

# User variables
MIRROR=${MIRROR:-"https://mirror.f4st.host/archlinux"}

function atexit() {
    popd >/dev/null
}
trap atexit EXIT

BASE=$(dirname $(readlink -f "$0"))
pushd "$BASE" >/dev/null

PKGS="pacman sed gzip"
ARCHSTRAP_DIST="/tmp/dist"
ARCH_IMAGEFILE="/opt/arch-strap.tar"
LOCAL_DIST=$(readlink -f $(pwd)/dist)
REALUID=$(id -ru)
REALGID=$(id -rg)

# docker stop arch-strap-builder || true
# docker rm arch-strap-builder || true

CONFIG="
[options]
NoExtract   = usr/share/doc/*
NoExtract   = usr/share/help/*
NoExtract   = usr/share/gtk-doc/*
NoExtract   = usr/share/i18n/* !usr/share/i18n/locales/en_US !usr/share/i18n/locales/en_GB !usr/share/i18n/locales/i18n !usr/share/i18n/locales/iso14651_* !usr/share/i18n/locales/translit_* !usr/share/i18n/charmaps/UTF-8.gz
NoExtract   = usr/share/iana-etc/*
NoExtract   = usr/share/locale/* !usr/share/locale/en_US/* !usr/share/locale/locale.alias
NoExtract   = usr/share/info/*
NoExtract   = usr/share/man/*
NoExtract   = usr/share/zoneinfo/* !usr/share/zoneinfo/UTC
NoExtract   = usr/share/vim/vim74/lang/* usr/share/licenses*
NoExtract   = usr/bin/modprobed_db
"

docker run --rm -ti \
           --privileged=true \
           --name arch-strap-builder \
           -v ${LOCAL_DIST}:/opt \
           -e REALUID=${REALUID} \
           -e REALGID=${REALGID} \
           ioriomauro/arch-iso:latest \
           /bin/bash -c "
set -ux -- && \
export PACCFG=$(mktemp) && \
cp /etc/pacman.conf \${PACCFG} && \
echo \"${CONFIG}\" >>\${PACCFG} && \
mkdir -p ${ARCHSTRAP_DIST} && \
pacstrap -cGM -C \${PACCFG} ${ARCHSTRAP_DIST} ${PKGS} && \
arch-chroot ${ARCHSTRAP_DIST} /usr/bin/sh -c '
    set -ux -- && \
    ln -nfs /usr/share/zoneinfo/UTC /etc/localtime && \
    echo \"en_US.UTF-8 UTF-8\" > /etc/locale.gen && \
    echo \"LANG=en_US.UTF-8\" >/etc/locale.conf && \
    echo \"Server = ${MIRROR}/\\\$repo/os/\\\$arch\" >/etc/pacman.d/mirrorlist && \
    echo \"${CONFIG}\" >>/etc/pacman.conf && \
    locale-gen && \
    echo -e \"Arch Linux\nBuild time: $(LANG=en_US date -u)\" > /RELEASE
' && \
echo \"Creating tar archive. This may take a while...\" && \
pacman --noconfirm -S tar && \
tar --numeric-owner --warning=no-file-ignored --xattrs --acls -C ${ARCHSTRAP_DIST} -acf ${ARCH_IMAGEFILE} . && \
ls -l /opt && \
chown ${REALUID}:${REALGID} ${ARCH_IMAGEFILE}
"

# Now that we have an image file we can build a real docker image
docker build -t ioriomauro/arch-base:$(LANG=en_US date +%Y.%m.%d) \
             -t ioriomauro/arch-base:latest \
             .
