#!/bin/bash
set -ue

BASEDIR=$(dirname $(readlink -f "$0"))

function atexit() {
    popd >/dev/null 2>/dev/null
}
trap atexit EXIT



pushd "$BASEDIR" >/dev/null 2>/dev/null

docker build -t ioriomauro/arch-cower-build:latest .

(
    echo -e "\n\n\n"
    echo "*************************************"
    echo "*****     Testing new image     *****"
    echo "*************************************"
    echo -e "\n\n\n"

    docker run  --rm -ti \
                -e UID=`id -ru` \
                -e GID=`id -rg` \
                ioriomauro/arch-cower-build:latest \
                    tmuxinator \
                    libcurl-openssl-1.0 \
                    perl \
                    pacaur
)
