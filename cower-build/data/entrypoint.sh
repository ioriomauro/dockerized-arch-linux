#!/bin/bash
set -ue

ARGS="$@"

sudo pacman -Syy --noconfirm
/usr/bin/bash -l /home/developer/build-pkgs.sh ${ARGS}

find /home/developer -iname "*.pkg.tar.xz" -exec sudo cp -v {} /packages/ \;
sudo chown ${UID}:${GID} /packages/*.pkg.tar.xz
