#!/bin/bash
set -ue

ARGS="$@"

pacman -Syy --noconfirm
su - developer -c "/home/developer/build-pkgs.sh ${ARGS}"

find /home/developer -iname "*.pkg.tar.xz" -exec cp {} /packages/ \;
chown ${UID}:${GID} /packages/*.pkg.tar.xz
