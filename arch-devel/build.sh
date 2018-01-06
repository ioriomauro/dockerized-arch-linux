#!/bin/bash
set -ue

BASEDIR=$(dirname $(readlink -f "$0"))

function atexit() {
    popd >/dev/null 2>/dev/null
}
trap atexit EXIT



pushd "$BASEDIR" >/dev/null 2>/dev/null

docker build -t ioriomauro/arch-devel:latest .
