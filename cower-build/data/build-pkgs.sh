#!/bin/bash
set -u

DEBUG=${DEBUG:-0}
if [ "$DEBUG" -eq "1" ]; then
    set -x
fi

# SYNOPSIS: build-pkgs.sh pkg1 pkg2 ... pkgN
#           pkg1..N are exact names of aur packages. Names can be searched
#           with "cower -s" and the filtered

deps=()
makedeps=()
arch_deps=()


function exists_in {
    local seeking=$1; shift
    local in=1
    for element; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}


function get_deps {
    for d in $(export CARCH=""; \
               source "$1"/*/PKGBUILD; \
               set +u --; \
               echo ${depends[@]}); do
        exists_in $d "${deps[@]}"
        if [ $? -eq 1 ]; then
            deps+=($d)
        fi
    done

    for d in $(export CARCH=""; \
               source "$1"/*/PKGBUILD; \
               set +u --; \
               echo ${makedepends[@]}); do
        exists_in $d "${makedeps[@]}"
        if [ $? -eq 1 ]; then
            makedeps+=($d)
        fi
    done
}


function download {
    echo -e "\t****************************************"
    echo -e "\t*****     Downloading ${1} ...     *****"
    echo -e "\t****************************************"
    if [ -d "${1}" ]; then
        echo -e "Skipping. Already downloaded"
        return 0
    fi

    mkdir "${1}"
    cower -dv --target "${1}" "${1}"
    if [ $? -ne 0 ]; then
        echo "${1} in official repo"
        exists_in ${1} "${arch_deps[@]}"
        if [ $? -eq 1 ]; then
            arch_deps+=(${1})
        fi
        return
    fi
    echo -e "\tBuilding deps list for ${1}"
    get_deps ${1}
    for d in $(echo ${makedeps[@]}); do
        download $d
    done
    for d in $(echo ${deps[@]}); do
        download $d
    done
}


function build_aur {
    pushd ${1}/*

    makepkg -i --skippgpcheck --noconfirm

    popd
}


BASE=$(dirname $(readlink -f "$0"))
cd "$BASE"
mkdir -p build; cd build

for pkg in "$@"; do
    download ${pkg}
    echo "Total deps: ${deps[@]}"
    echo "Total makedeps: ${makedeps[@]}"
    echo "Total arch deps: ${arch_deps[@]}"

    echo "Installing arch deps"
    if [ ${#arch_deps[@]} -ne 0 ]; then
        sudo pacman -S --needed --noconfirm ${arch_deps[@]}
    fi

    echo "Installing makedeps"
    for d in ${makedeps[@]}; do
        exists_in $d "${arch_deps[@]}"
        if [ $? -eq 0 ]; then
            continue
        fi

        sudo pacman -S --needed --noconfirm $d
        if [ $? -eq 1 ]; then
            build_aur $d
        fi
    done

    echo "Installing aur deps"
    for d in ${deps[@]}; do
        exists_in $d "${arch_deps[@]}"
        if [ $? -eq 0 ]; then
            continue
        fi

        exists_in $d "${makedeps[@]}"
        if [ $? -eq 0 ]; then
            continue
        fi

        build_aur $d
    done

    echo "Installing ${pkg}"
    exists_in ${pkg} "${arch_deps[@]}"
    if [ $? -eq 0 ]; then
        continue
    fi

    exists_in ${pkg} "${makedeps[@]}"
    if [ $? -eq 0 ]; then
        continue
    fi

    exists_in ${pkg} "${deps[@]}"
    if [ $? -eq 0 ]; then
        continue
    fi

    build_aur ${pkg}
done
