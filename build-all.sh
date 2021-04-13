#!/bin/bash
set -ue

if [ -f arch-base/dist/arch-strap.tar ]; then
    rm -fv arch-base/dist/arch-strap.tar
fi

for dist in  arch-iso arch-base arch-devel cower cower-build; do
    pushd $(readlink -f "$dist")
    echo Building "$dist"
    ./build.sh
    popd
done
