#!/bin/bash
set -ue

ARGS="$@"
PAC_ARGS=""
IGNORE_PACMAN_MIRRORS=${IGNORE_PACMAN_MIRRORS:-0}
if [ "$IGNORE_PACMAN_MIRRORS" -eq "1" ]; then
    PAC_ARGS="--ignore pacman-mirrorlist"
fi


sudo pacman -Syyu $PAC_ARGS --noconfirm
/usr/bin/bash -l /home/developer/build-pkgs.sh ${ARGS}

find /home/developer -iname "*.pkg.tar.xz" -exec sudo cp -v {} /packages/ \;
sudo chown ${UID}:${GID} /packages/*.pkg.tar.xz
