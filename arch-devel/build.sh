#!/bin/bash
set -ue

BASEDIR=$(dirname $(readlink -f "$0"))

function atexit() {
    popd >/dev/null
}
trap atexit EXIT



pushd "$BASEDIR" >/dev/null

docker build -t ioriomauro/arch-devel:latest \
             -t ioriomauro/arch-devel:$(LANG=en_US date +%Y.%m.%d) \
             .

(
    echo -e "\n\n\n"
    echo "*************************************"
    echo "*****     Testing new image     *****"
    echo "*************************************"
    echo -e "\n\n\n"

    SRC='
    #include <stdio.h>  // Luckily this is a bash comment. No escape required.

    int main(void) {
        printf(\"Hello, World!\\n\");
        return 0;
    }
    '

    docker run --rm -ti ioriomauro/arch-devel:latest /usr/bin/bash -c "
        set -ux -- && \
        cd && \
        echo \"${SRC}\" >test.c && \
        gcc -Wall -o test test.c && ./test && \
        curl -LO 'https://curl.haxx.se/download/curl-7.59.0.tar.gz' && \
        sha1sum curl-7.59.0.tar.gz > sha1sums.txt && \
        tar xf curl-7.59.0.tar.gz && \
        cd curl-7.59.0 && \
        ./configure \
            --prefix=/usr/local             \
            --with-random=/dev/urandom      \
            --enable-static                 \
            --enable-threaded-resolver      \
            --with-ca-path=/etc/ssl/certs   \
            --enable-ipv6 && \
        make && sudo make install && \
        cd .. && \
        /usr/local/bin/curl -V && \
        rm -f curl-7.59.0.tar.gz && \
        /usr/local/bin/curl -LO 'https://curl.haxx.se/download/curl-7.59.0.tar.gz' && \
        sha1sum -c sha1sums.txt
    "
)
