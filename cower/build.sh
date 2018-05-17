#!/bin/bash
set -ue

BASEDIR=$(dirname $(readlink -f "$0"))

function atexit() {
    popd >/dev/null 2>/dev/null
}
trap atexit EXIT



pushd "$BASEDIR" >/dev/null 2>/dev/null

docker build -t ioriomauro/arch-cower:latest .

(
    echo -e "\n\n\n"
    echo "*************************************"
    echo "*****     Testing new image     *****"
    echo "*************************************"
    echo -e "\n\n\n"

    set -e
    docker run --rm -ti ioriomauro/arch-cower:latest -vs cower
    docker run --rm -ti ioriomauro/arch-cower:latest -V
)
