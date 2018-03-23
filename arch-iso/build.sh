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

(
    echo -e "\n\n\n"
    echo "*************************************"
    echo "*****     Testing new image     *****"
    echo "*************************************"
    echo -e "\n\n\n"

    docker run --rm -ti ioriomauro/arch-iso:latest /usr/bin/bash -c "
        set -ux -- && \
        pacman --noconfirm -S sudo && \
        useradd -m -G wheel -s /bin/bash developer && \
        echo '%wheel ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/developer && \
        if [ \$(su -lc 'sudo whoami' developer) != 'root' ]; then
            exit 1;
        fi
    "
)
