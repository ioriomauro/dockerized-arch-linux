#!/bin/bash
set -ue

function atexit() {
    popd >/dev/null
}
trap atexit EXIT

BASE=$(dirname $(readlink -f "0"))
pushd "$BASE" >/dev/null

VER=$(date +%Y.%m.01)

docker build --build-arg ISO_VER=${VER} \
             -t ioriomauro/arch-iso:${VER} \
             -t ioriomauro/arch-iso:latest \
             .
