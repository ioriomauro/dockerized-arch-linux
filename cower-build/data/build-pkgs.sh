#!/bin/bash
set -ue

ARGS="$@"

mkdir -p build; cd build

for pkg in ${ARGS}; do
    echo "Building ${pkg}"
    cower -dv "${pkg}"
    pushd "${pkg}" >/dev/null
    makepkg -s --noconfirm
    popd >/dev/null
done
